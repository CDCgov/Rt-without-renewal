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

```jldoctest RandomWalk; output = false
using Distributions, Turing, EpiAware
rw = RandomWalk()
rw
nothing
# output
```

```jldoctest RandomWalk; output = false
mdl = generate_latent(rw, 10)
mdl()
nothing
# output
```

```jldoctest RandomWalk; output = false
rand(mdl)
nothing
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
