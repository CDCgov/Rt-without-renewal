@doc raw"
Model latent process ``Z_t`` as a random walk.

## Mathematical specification

The random walk ``Z_t`` is specified as a parameteric transformation of the white noise
sequence ``(\epsilon_t)_{t\geq 1}``,

```math
Z_t = Z_0 + \sigma \sum_{i = 1}^t \epsilon_t
```

Constructing a random walk requires specifying:
- An `init_prior` as a prior for ``Z_0``. Default is `Normal()`.
- A `std_prior` for ``\sigma``. The default is HalfNormal with a mean of 0.25.
- An `ϵ_t` prior for the white noise sequence. The default is `IID(Normal())`.

## Constructors

- `RandomWalk(init_prior::Sampleable, ϵ_t::AbstractTuringLatentModel)`: Constructs a random walk model with the specified prior distributions for the initial condition and white noise sequence.
- `RandomWalk(; init_prior::Sampleable = Normal(), ϵ_t::AbstractTuringLatentModel = HierarchicalNormal())`: Constructs a random walk model with the specified prior distributions for the initial condition and white noise sequence.

## Example usage

```jldoctest RandomWalk
using Distributions, Turing, EpiAware
rw = RandomWalk()
rw
# output
RandomWalk{Normal{Float64}, HierarchicalNormal{Float64, Truncated{Normal{Float64}, Continuous, Float64, Float64, Float64}}}(Distributions.Normal{Float64}(μ=0.0, σ=1.0), HierarchicalNormal{Float64, Truncated{Normal{Float64}, Continuous, Float64, Float64, Float64}}(0.0, Truncated(Distributions.Normal{Float64}(μ=0.0, σ=0.1); lower=0.0, upper=Inf)))
```

```jldoctest RandomWalk; filter=r\"\b\d+(\.\d+)?\b\" => \"*\"
mdl = generate_latent(rw, 10)
mdl()
10-element Vector{Float64}:
  0.09863550369060489
 -0.1012648767758989
  0.012856292122216312
  0.1387603166701943
  0.477837117521154
  0.7160833490012614
  0.7586022515587051
  0.8488849623077518
  0.8957122109706586
  0.539681134401317
# output
```

```jldoctest RandomWalk; filter=r\"\b\d+(\.\d+)?\b\" => \"*\"
rand(mdl)
(rw_init = 0.07403248756671234, std = 0.1301785729462533, ϵ_t = [3.5710804551384614, -0.33297910177560924, 0.26287022218436157, 0.734726235372338, 0.36811479244419343, 3.02370788975943, 1.0653760418203968, 1.167408826654517, -0.6950266553756028])
# output
```
"
@kwdef struct RandomWalk{
    D <: Sampleable, E <: AbstractTuringLatentModel} <:
              AbstractTuringLatentModel
    init_prior::D = Normal()
    ϵ_t::E = HierarchicalNormal()
end

@doc raw"
Generate a latent RW series using accumulate_scan.

# Arguments

- `latent_model::RandomWalk`: The RandomWalk model.
- `n::Int`: The length of the RW series.

# Returns
- `rw::Vector{Float64}`: The generated RW series.

# Notes
- `n` must be greater than 0.
"
@model function EpiAwareBase.generate_latent(latent_model::RandomWalk, n)
    @assert n>0 "n must be greater than 0"

    rw_init ~ latent_model.init_prior
    @submodel ϵ_t = generate_latent(latent_model.ϵ_t, n - 1)

    rw = accumulate_scan(RWStep(), rw_init, ϵ_t)

    return rw
end

@doc raw"
The random walk (RW) step function struct
"
struct RWStep <: AbstractAccumulationStep end

@doc raw"
The random walk (RW) step function for use with `accumulate_scan`.
"
function (rw::RWStep)(state, ϵ)
    new_val = state + ϵ
    return new_val
end
