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
- An `ϵ_t` prior for the white noise sequence. The default is `IDD(Normal())`.

## Constructors

- `RandomWalk(; init_prior, std_prior, ϵ_t)`

## Example usage

```jldoctest RandomWalk
using Distributions, Turing, EpiAware
rw = RandomWalk()
rw
# output
RandomWalk{Normal{Float64}, HalfNormal{Float64}, IDD{Normal{Float64}}}(init_prior=Normal{Float64}(μ=0.0, σ=1.0), std_prior=HalfNormal{Float64}(σ=0.25), ϵ_t=IDD{Normal{Float64}}(ϵ_t=Normal{Float64}(μ=0.0, σ=1.0)))
```

```jldoctest RandomWalk; filter=r\"\b\d+(\.\d+)?\b\" => \"*\"
mdl = generate_latent(rw, 10)
mdl()
# output
```

```jldoctest RandomWalk; filter=r\"\b\d+(\.\d+)?\b\" => \"*\"
rand(mdl)
# output
```
"
@kwdef struct RandomWalk{
    D <: Sampleable, S <: Sampleable, E <: AbstractTuringLatentModel} <:
              AbstractTuringLatentModel
    init_prior::D = Normal()
    std_prior::S = HalfNormal(0.25)
    ϵ_t::E = IDD(Normal())
end

function RandomWalk(init_prior::D, std_prior::S) where {D <: Sampleable, S <: Sampleable}
    return RandomWalk(; init_prior = init_prior, std_prior = std_prior)
end

@doc raw"
Implement the `generate_latent` function for the `RandomWalk` model.

## Example usage of `generate_latent` with `RandomWalk` type of latent process model

```julia
using Distributions, Turing, EpiAware

# Create a RandomWalk model
rw = RandomWalk(init_prior = Normal(2., 1.),
                                std_prior = HalfNormal(0.1))
```

Then, we can use `generate_latent` to construct a Turing model for a 10 step random walk.

```julia
# Construct a Turing model
rw_model = generate_latent(rw, 10)
```

Now we can use the `Turing` PPL API to sample underlying parameters and generate the
unobserved infections.

```julia
#Sample random parameters from prior
θ = rand(rw_model)
#Get random walk sample path as a generated quantities from the model
Z_t, _ = generated_quantities(rw_model, θ)
```
"
@model function EpiAwareBase.generate_latent(latent_model::RandomWalk, n)
    σ_RW ~ latent_model.std_prior
    rw_init ~ latent_model.init_prior
    @submodel ϵ_t = generate_latent(latent_model.ϵ_t, n - 1)
    rw = rw_init .+ vcat(0.0, σ_RW .* cumsum(ϵ_t))
    return rw
end
