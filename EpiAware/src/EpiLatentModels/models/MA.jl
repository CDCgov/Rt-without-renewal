@doc raw"
The moving average (MA) model struct.

# Constructors
- `MA(θ::Distribution, σ::Distribution; q::Int = 1, ϵ::AbstractTuringLatentModel = IDD(Normal()))`: Constructs an MA model with the specified prior distributions.

- `MA(; θ::Vector{C} = [truncated(Normal(0.0, 0.05), -1, 1)], σ::Distribution = HalfNormal(0.1), ϵ::AbstractTuringLatentModel = HierarchicalNormal) where {C <: Distribution}`: Constructs an MA model with the specified prior distributions.

- `MA(θ::Distribution, q::Int, ϵ_t::AbstractTuringLatentModel)`: Constructs an MA model with the specified prior distributions and order.

# Parameters
- `θ`: Prior distribution for the MA coefficients. For MA(q), this should be a vector of q distributions or a multivariate distribution of dimension q.
- `q`: Order of the MA model, i.e., the number of lagged error terms.
- `ϵ_t`: Distribution of the error term, typically standard normal.

# Examples

```jldoctest MA
using Distributions, Turing, EpiAware
ma = MA()
ma
# output

```

```jldoctest MA; filter = r\"\b\d+(\.\d+)?\b\" => \"*\"
mdl = generate_latent(ma, 10)
mdl()
# output
```

```jldoctest MA; filter = r\"\b\d+(\.\d+)?\b\" => \"*\"
rand(mdl)
# output
```
"

struct MA{C <: Sampleable, S <: Sampleable, Q <: Int, E <: AbstractTuringLatentModel} <:
       AbstractTuringLatentModel
    "Prior distribution for the MA coefficients. For MA(q), this should be a vector of q distributions or a multivariate distribution of dimension q"
    θ::C
    "Order of the MA model, i.e., the number of lagged error terms."
    q::Q
    "Prior distribution for the error term."
    ϵ_t::E

    function MA(θ::Distribution, σ::Distribution;
            q::Int = 1, ϵ::AbstractTuringLatentModel = IDD(Normal()))
        θ_priors = fill(θ, q)
        return MA(; θ_priors = θ_priors, σ = σ, ϵ = ϵ)
    end

    function MA(; θ_priors::Vector{C} = [truncated(Normal(0.0, 0.05), -1, 1)],
            σ::Distribution = HalfNormal(0.1),
            ϵ::AbstractTuringLatentModel = IDD(Normal())) where {C <: Distribution}
        q = length(θ_priors)
        θ = _expand_dist(θ_priors)
        return MA(θ, q, ϵ)
    end

    function MA(θ::Distribution, q::Int, ϵ::AbstractTuringLatentModel)
        @assert q>0 "q must be greater than 0"
        @assert q==length(θ) "q must be equal to the length of θ"
        new{typeof(θ), typeof(σ), typeof(q), typeof(ϵ)}(
            θ, q, ϵ
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
    θ ~ latent_model.θ
    @submodel ϵ_t = generate_latent(latent_model.ϵ, n)

    ma = accumulate_scan(
        MAStep(θ),
        (; val = 0, state = ϵ_t[1:q]), ϵ_t[(q + 1):end])

    return ma
end

@doc raw"
The moving average (MA) step function struct
"
struct MAStep{C <: AbstractVector{<:Real}} <: AbstractAccumulationStep
    θ::C
end

@doc raw"
The moving average (MA) step function for use with `accumulate_scan`.
"
function (ma::MAStep)(state, ϵ)
    new_val = ϵ + dot(ma.θ, state.state)
    new_state = vcat(ϵ, state.state[1:(end - 1)])
    return (; val = new_val, state = new_state)
end

@doc raw"
The MA step function method for get_state.
"
function EpiAwareUtils.get_state(acc_step::MAStep, initial_state, state)
    init_vals = initial_state.state
    new_vals = state .|> x -> x.val
    return vcat(init_vals, new_vals)
end
