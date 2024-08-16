@doc raw"
The moving average (MA) model struct.

# Constructors
- `MA(coef_prior::Distribution, std_prior::Distribution; q::Int = 1, ϵ_t::AbstractTuringLatentModel = IDD(Normal()))`: Constructs an MA model with the specified prior distributions for MA coefficients and standard deviation. The order of the MA model and the error term distribution can also be specified.

- `MA(; coef_priors::Vector{C} = [truncated(Normal(0.0, 0.05), -1, 1)], std_prior::Distribution = HalfNormal(0.1), ϵ_t::AbstractTuringLatentModel = IDD(Normal())) where {C <: Distribution}`: Constructs an MA model with the specified prior distributions for MA coefficients, standard deviation, and error term. The order of the MA model is determined by the length of the `coef_priors` vector.

- `MA(coef_prior::Distribution, std_prior::Distribution, q::Int, ϵ_t::AbstractTuringLatentModel)`: Constructs an MA model with the specified prior distributions for MA coefficients, standard deviation, and error term. The order of the MA model is explicitly specified.

# Examples

```jldoctest; filter = r\"\b\d+(\.\d+)?\b\" => \"*\"
using EpiAware, Distributions
ma = MA(Normal(0.0, 0.05), HalfNormal(0.1); q = 7)
ma_model = generate_latent(ma, 10)
ma_model()

# output

```
"
struct MA{C <: Sampleable, S <: Sampleable, Q <: Int, E <: AbstractTuringLatentModel} <:
       AbstractTuringLatentModel
    "Prior distribution for the MA coefficients."
    coef_prior::C
    "Prior distribution for the standard deviation."
    std_prior::S
    "Order of the MA model."
    q::Q
    "Prior distribution for the error term."
    ϵ_t::E

    function MA(coef_prior::Distribution, std_prior::Distribution;
            q::Int = 1, ϵ_t::AbstractTuringLatentModel = IDD(Normal()))
        coef_priors = fill(coef_prior, q)
        return MA(; coef_priors = coef_priors, std_prior = std_prior, ϵ_t = ϵ_t)
    end

    function MA(; coef_priors::Vector{C} = [truncated(Normal(0.0, 0.05), -1, 1)],
            std_prior::Distribution = HalfNormal(0.1),
            ϵ_t::AbstractTuringLatentModel = IDD(Normal())) where {C <: Distribution}
        q = length(coef_priors)
        coef_prior = _expand_dist(coef_priors)
        return MA(coef_prior, std_prior, q, ϵ_t)
    end

    function MA(coef_prior::Distribution, std_prior::Distribution,
            q::Int, ϵ_t::AbstractTuringLatentModel)
        @assert q>0 "q must be greater than 0"
        @assert q==length(coef_prior) "q must be equal to the length of coef_prior"
        new{typeof(coef_prior), typeof(std_prior), typeof(q), typeof(ϵ_t)}(
            coef_prior, std_prior, q, ϵ_t
        )
    end
end

@doc raw"
Generate a latent MA series.

# Arguments

- `latent_model::MA`: The MA model.
- `n::Int`: The length of the MA series.

# Returns
- `ma::Vector{Float64}`: The generated MA series.

# Notes
- `n` must be longer than the order of the moving average process.
"
@model function EpiAwareBase.generate_latent(latent_model::MA, n)
    q = latent_model.q
    @assert n>q "n must be longer than order of the moving average process"

    σ_MA ~ latent_model.std_prior
    coef_MA ~ latent_model.coef_prior
    @submodel ϵ_t = generate_latent(latent_model.ϵ_t, n)
    scaled_ϵ_t = σ_MA * ϵ_t

    ma = accumulate_scan(MAStep(coef_MA), scaled_ϵ_t[1:q], scaled_ϵ_t[(q + 1):end])

    return ma
end

@doc raw"
The moving average (MA) step function struct
"
struct MAStep{C <: AbstractVector{<:Real}} <: AbstractAccumulationStep
    coef_MA::C
end

@doc raw"
The moving average (MA) step function for use with `accumulate_scan`.
"
function (ma::MAStep)(state, ϵ)
    new_val = ϵ + dot(ma.coef_MA, state)
    new_state = vcat(ϵ, state[1:(end - 1)])
    return new_state
end
