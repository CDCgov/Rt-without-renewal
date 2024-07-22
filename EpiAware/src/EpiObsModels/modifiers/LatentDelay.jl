@doc raw"
The `LatentDelay` struct represents an observation model that introduces a latent delay in the observations. It is a subtype of `AbstractTuringObservationModel`.

Note that the `LatentDelay` observation model shortens the observation vector by the length of the delay distribution and this is then passed to the underlying observation model. This is to prevent fitting to partially
observed data.

## Fields
- `model::M`: The underlying observation model.
- `rev_pmf::T`: The probability mass function (PMF) representing the delay distribution reversed.

## Constructors
- `LatentDelay(model::M, distribution::C; D = nothing, Δd = 1.0)
    where {M <: AbstractTuringObservationModel, C <: ContinuousDistribution}`: Constructs
    a `LatentDelay` object with the given underlying observation model and continuous
    distribution. The `D` parameter specifies the right truncation of the distribution,
    with default `D = nothing` indicates that the distribution should be truncated
    at its 99th percentile rounded to nearest multiple of `Δd`. The `Δd` parameter specifies the
    width of each delay interval.

- `LatentDelay(model::M, pmf::T) where {M <: AbstractTuringObservationModel, T <: AbstractVector{<:Real}}`: Constructs a `LatentDelay` object with the given underlying observation model and delay PMF.

## Examples
```julia
using Distributions, Turing, EpiAware
obs = LatentDelay(NegativeBinomialError(), truncated(Normal(5.0, 2.0), 0.0, Inf))
obs_model = generate_observations(obs, missing, fill(10, 30))
obs_model()
```
"
struct LatentDelay{M <: AbstractTuringObservationModel, T <: AbstractVector{<:Real}} <:
       AbstractTuringObservationModel
    model::M
    rev_pmf::T

    function LatentDelay(model::M, distribution::C; D = nothing,
            Δd = 1.0) where {
            M <: AbstractTuringObservationModel, C <: ContinuousDistribution}
        pmf = censored_pmf(distribution; Δd = Δd, D = D)
        return LatentDelay(model, pmf)
    end

    function LatentDelay(model::M,
            pmf::T) where {M <: AbstractTuringObservationModel, T <: AbstractVector{<:Real}}
        @assert all(pmf .>= 0) "Delay interval must be non-negative"
        @assert isapprox(sum(pmf), 1) "Delay interval must sum to 1"
        rev_pmf = reverse(pmf)
        new{typeof(model), typeof(rev_pmf)}(model, rev_pmf)
    end
end

@doc raw"
Generates observations based on the `LatentDelay` observation model.

## Arguments
- `obs_model::LatentDelay`: The `LatentDelay` observation model.
- `y_t`: The current observations.
- `I_t`: The current infection indicator.

## Returns
- `y_t`: The updated observations.

"
@model function EpiAwareBase.generate_observations(obs_model::LatentDelay, y_t, Y_t)
    if ismissing(y_t)
        y_t = Vector{Missing}(missing, length(Y_t))
    end

    pmf_length = length(obs_model.rev_pmf)
    @assert pmf_length<=length(Y_t) "The delay PMF must be shorter than or equal to the observation vector"

    expected_obs = accumulate_scan(
        LDStep(obs_model.rev_pmf),
        (; val = 0, current = Y_t[1:(pmf_length)]),
        vcat(Y_t[(pmf_length + 1):end], 0.0)
    )

    @submodel y_t = generate_observations(
        obs_model.model, y_t, expected_obs)

    return y_t
end

@doc raw"
The LatentDelay step function struct
"
struct LDStep{D <: AbstractVector{<:Real}} <: AbstractAccumulationStep
    rev_pmf::D
end

@doc raw"
The LatentDelay step function method for `accumulate_scan`.
"
function (ld::LDStep)(state, ϵ)
    val = dot(ld.rev_pmf, state.current)
    current = vcat(state.current[2:end], ϵ)
    return (; val, current)
end

@doc raw"
The LatentDelay step function method for get_state.
"
function EpiAwareUtils.get_state(acc_step::LDStep, initial_state, state)
    return state .|> x -> x.val
end
