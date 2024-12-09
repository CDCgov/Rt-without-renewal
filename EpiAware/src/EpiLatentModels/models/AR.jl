@doc raw"
The autoregressive (AR) model struct.

# Constructors
- `AR(damp_prior::Sampleable, init_prior::Sampleable; p::Int = 1, ϵ_t::AbstractTuringLatentModel = HierarchicalNormal())`: Constructs an AR model with the specified prior distributions for damping coefficients and initial conditions. The order of the AR model can also be specified.

- `AR(; damp_priors::Vector{D} = [truncated(Normal(0.0, 0.05), 0, 1)], init_priors::Vector{I} = [Normal()], ϵ_t::AbstractTuringLatentModel = HierarchicalNormal()) where {D <: Sampleable, I <: Sampleable}`: Constructs an AR model with the specified prior distributions for damping coefficients and initial conditions. The order of the AR model is determined by the length of the `damp_priors` vector.

# Examples

```jldoctest AR
using Distributions, Turing, EpiAware
ar = AR()
ar
# output
AR{Product{Continuous, Truncated{Normal{Float64}, Continuous, Float64, Float64, Float64}, FillArrays.Fill{Truncated{Normal{Float64}, Continuous, Float64, Float64, Float64}, 1, Tuple{Base.OneTo{Int64}}}}, DistributionsAD.TuringScalMvNormal{Vector{Float64}, Float64}, Int64, HierarchicalNormal{Float64, Truncated{Normal{Float64}, Continuous, Float64, Float64, Float64}}}(Distributions.Product{Distributions.Continuous, Distributions.Truncated{Distributions.Normal{Float64}, Distributions.Continuous, Float64, Float64, Float64}, FillArrays.Fill{Distributions.Truncated{Distributions.Normal{Float64}, Distributions.Continuous, Float64, Float64, Float64}, 1, Tuple{Base.OneTo{Int64}}}}(v=Fill(Truncated(Distributions.Normal{Float64}(μ=0.0, σ=0.05); lower=0.0, upper=1.0), 1)), DistributionsAD.TuringScalMvNormal{Vector{Float64}, Float64}(m=[0.0], σ=1.0), 1, HierarchicalNormal{Float64, Truncated{Normal{Float64}, Continuous, Float64, Float64, Float64}}(0.0, Truncated(Distributions.Normal{Float64}(μ=0.0, σ=0.1); lower=0.0, upper=Inf)))
```

```jldocttest AR; filter = r\"\b\d+(\.\d+)?\b\" => \"*\"
mdl = generate_latent(ar, 10)
mdl()
# output
```

```jldoctest AR; filter = r\"\b\d+(\.\d+)?\b\" => \"*\"
rand(mdl)
ERROR: UndefVarError: `mdl` not defined in `Main`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
 [1] top-level scope
   @ none:1
ERROR: UndefVarError: `mdl` not defined in `Main`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
 [1] top-level scope
   @ none:1
# output
```
"
struct AR{D <: Sampleable, I <: Sampleable,
    P <: Int, E <: AbstractTuringLatentModel} <: AbstractTuringLatentModel
    "Prior distribution for the damping coefficients."
    damp_prior::D
    "Prior distribution for the initial conditions"
    init_prior::I
    "Order of the AR model."
    p::P
    "Prior distribution for the error term."
    ϵ_t::E

    function AR(damp_prior::Sampleable, init_prior::Sampleable; p::Int = 1,
            ϵ_t::AbstractTuringLatentModel = HierarchicalNormal())
        damp_priors = fill(damp_prior, p)
        init_priors = fill(init_prior, p)
        return AR(; damp_priors = damp_priors, init_priors = init_priors, ϵ_t = ϵ_t)
    end

    function AR(; damp_priors::Vector{D} = [truncated(Normal(0.0, 0.05), 0, 1)],
            init_priors::Vector{I} = [Normal()],
            ϵ_t::AbstractTuringLatentModel = HierarchicalNormal()) where {
            D <: Sampleable, I <: Sampleable}
        p = length(damp_priors)
        damp_prior = _expand_dist(damp_priors)
        init_prior = _expand_dist(init_priors)
        return AR(damp_prior, init_prior, p, ϵ_t)
    end

    function AR(damp_prior::Sampleable, init_prior::Sampleable,
            p::Int, ϵ_t::AbstractTuringLatentModel)
        @assert p>0 "p must be greater than 0"
        @assert p==length(damp_prior)==length(init_prior) "p must be equal to the length of damp_prior and init_prior"
        new{typeof(damp_prior), typeof(init_prior), typeof(p), typeof(ϵ_t)}(
            damp_prior, init_prior, p, ϵ_t)
    end
end

@doc raw"
Generate a latent AR series.

# Arguments

- `latent_model::AR`: The AR model.
- `n::Int`: The length of the AR series.

# Returns
- `ar::Vector{Float64}`: The generated AR series.

# Notes
- The length of `damp_prior` and `init_prior` must be the same.
- `n` must be longer than the order of the autoregressive process.
"
@model function EpiAwareBase.generate_latent(latent_model::AR, n)
    p = latent_model.p
    @assert n>p "n must be longer than order of the autoregressive process"

    ar_init ~ latent_model.init_prior
    damp_AR ~ latent_model.damp_prior
    @submodel ϵ_t = generate_latent(latent_model.ϵ_t, n - p)

    ar = accumulate_scan(ARStep(damp_AR), ar_init, ϵ_t)

    return ar
end

@doc raw"
The autoregressive (AR) step function struct
"
struct ARStep{D <: AbstractVector{<:Real}} <: AbstractAccumulationStep
    damp_AR::D
end

@doc raw"
The autoregressive (AR) step function for use with `accumulate_scan`.
"
function (ar::ARStep)(state, ϵ)
    new_val = dot(ar.damp_AR, state) + ϵ
    new_state = vcat(state[2:end], new_val)
    return new_state
end
