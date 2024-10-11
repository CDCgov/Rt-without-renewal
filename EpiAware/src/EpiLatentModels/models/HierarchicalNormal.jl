@doc raw"
The `HierarchicalNormal` struct represents a non-centered hierarchical normal distribution.

## Constructors

- `HierarchicalNormal(mean, std_prior)`: Constructs a `HierarchicalNormal` instance with the specified mean and standard deviation prior.
- `HierarchicalNormal(; mean = 0.0, std_prior = truncated(Normal(0,0.1), 0, Inf))`: Constructs a `HierarchicalNormal` instance with the specified mean and standard deviation prior using named arguments and with default values.
- `HierarchicalNormal(std_prior)`: Constructs a `HierarchicalNormal` instance with the specified standard deviation prior.
## Examples

```jldoctest HierarchicalNormal
using Distributions, Turing, EpiAware
hn = HierarchicalNormal()
# output
HierarchicalNormal{Float64, Truncated{Normal{Float64}, Continuous, Float64}}(mean=0.0, std_prior=Truncated{Normal{Float64}, Continuous, Float64}(a=0.0, b=Inf, x=Normal{Float64}(μ=0.0, σ=0.1)))
```

```jldoctest HierarchicalNormal; filter=r\"\b\d+(\.\d+)?\b\" => \"*\"
mdl = generate_latent(hn, 10)
mdl()
# output
```

```jldoctest HierarchicalNormal; filter=r\"\b\d+(\.\d+)?\b\" => \"*\"
rand(mdl)
# output
```
"
@kwdef struct HierarchicalNormal{R <: Real, D <: Sampleable} <: AbstractTuringLatentModel
    "Mean of the normal distribution."
    mean::R = 0.0
    "Prior distribution for the standard deviation."
    std_prior::D = truncated(Normal(0, 0.1), 0, Inf)
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
    @submodel ϵ_t = generate_latent(IDD(Normal()), n)

    η_t = obs_model.mean .+ std .* ϵ_t
    return η_t
end
