@doc raw"
The `HierarchicalNormal` struct represents a non-centered hierarchical normal distribution.

## Constructors

- `HierarchicalNormal(mean, std_prior)`: Constructs a `HierarchicalNormal` instance with the specified mean and standard deviation prior.
- `HierarchicalNormal(; mean = 0.0, std_prior = truncated(Normal(0,1), 0, Inf))`: Constructs a `HierarchicalNormal` instance with the specified mean and standard deviation prior using named arguments and with default values.

## Examples

```julia
using Distributions, EpiAware
hnorm = HierarchicalNormal(0.0, truncated(Normal(0, 1), 0, Inf))
hnorm_model = generate_latent(hnorm, 10)
hnorm_model()
```
"
@kwdef struct HierarchicalNormal{R <: Real, D <: Sampleable} <: AbstractTuringLatentModel
    mean::R = 0.0
    std_prior::D = truncated(Normal(0, 1), 0, Inf)
end

@doc raw"
    function EpiAwareBase.generate_latent(obs_model::HierarchicalNormal, n)

Generate latent variables from the hierarchical normal distribution.

# Arguments
- `obs_model::HierarchicalNormal`: The hierarchical normal distribution model.
- `n`: Number of latent variables to generate.

# Returns
- `η_t`: Generated latent variables.
- `std`: Standard deviation used in the generation.
"
@model function EpiAwareBase.generate_latent(obs_model::HierarchicalNormal, n)
    std ~ obs_model.std_prior
    @submodel ϵ_t = generate_latent(IDD(Normal()), n)

    η_t = obs_model.mean .+ std .* ϵ_t
    return η_t, (; std = std)
end
