@doc raw"
The `HierarchicalNormal` struct represents a non-centered hierarchical normal distribution.

## Constructors

- `HierarchicalNormal(mean, std_prior)`: Constructs a `HierarchicalNormal` instance with the specified mean and standard deviation prior.
- `HierarchicalNormal(; mean = 0.0, std_prior = truncated(Normal(0,0.1), 0, Inf))`: Constructs a `HierarchicalNormal` instance with the specified mean and standard deviation prior using named arguments and with default values.
- `HierarchicalNormal(std_prior)`: Constructs a `HierarchicalNormal` instance with the specified standard deviation prior.
- `HierarchicalNormal(mean, std_prior)`: Constructs a `HierarchicalNormal` instance with the specified mean and standard deviation prior.

## Examples

```jldoctest HierarchicalNormal; output = false
using Distributions, Turing, EpiAware
hn = HierarchicalNormal()

mdl = generate_latent(hn, 10)
mdl()

rand(mdl)
nothing
┌ Warning: `@submodel model` and `@submodel prefix=... model` are deprecated; see `to_submodel` for the up-to-date syntax.
│   caller = ip:0x0
└ @ Core :-1
┌ Warning: `@submodel model` and `@submodel prefix=... model` are deprecated; see `to_submodel` for the up-to-date syntax.
│   caller = ip:0x0
└ @ Core :-1
# output
```
"
@kwdef struct HierarchicalNormal{R <: Real, D <: Sampleable, M <: Bool} <:
              AbstractTuringLatentModel
    "Mean of the normal distribution."
    mean::R = 0.0
    "Prior distribution for the standard deviation."
    std_prior::D = truncated(Normal(0, 0.1), 0, Inf)
    "Flag to indicate if mean should be added (false when mean = 0)"
    add_mean::M = mean != 0
end

function HierarchicalNormal(std_prior::Distribution)
    return HierarchicalNormal(; std_prior = std_prior)
end

function HierarchicalNormal(mean::Real, std_prior::Distribution)
    return HierarchicalNormal(mean, std_prior, mean != 0)
end

@doc raw"
    function EpiAwareBase.generate_latent(obs_model::HierarchicalNormal, n)

Generate latent variables from the hierarchical normal distribution.

# Arguments
- `obs_model::HierarchicalNormal`: The hierarchical normal distribution model.
- `n`: Number of latent variables to generate.

# Returns
- `η_t`: Generated latent variables.
"
@model function EpiAwareBase.generate_latent(obs_model::HierarchicalNormal, n)
    std ~ obs_model.std_prior
    @submodel ϵ_t = generate_latent(IID(Normal()), n)

    η_t = obs_model.add_mean ? obs_model.mean .+ std * ϵ_t : std * ϵ_t
    return η_t
end
