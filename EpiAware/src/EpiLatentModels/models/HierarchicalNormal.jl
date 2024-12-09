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
HierarchicalNormal{Float64, Truncated{Normal{Float64}, Continuous, Float64, Float64, Float64}}(0.0, Truncated(Distributions.Normal{Float64}(μ=0.0, σ=0.1); lower=0.0, upper=Inf))
```

```jldoctest HierarchicalNormal; filter=r\"\b\d+(\.\d+)?\b\" => \"*\"
mdl = generate_latent(hn, 10)
mdl()
10-element Vector{Float64}:
  0.11952802822582498
 -0.005664808192809956
 -0.05920185382433839
  0.0005433144739374012
  0.14171480363042285
  0.06692368514086114
 -0.12671541365766306
 -0.04857470780547727
 -0.0781861277601833
  0.014917936490780714
# output
```

```jldoctest HierarchicalNormal; filter=r\"\b\d+(\.\d+)?\b\" => \"*\"
rand(mdl)
(std = 0.0765751560370051, ϵ_t = [-0.34458636199844195, -1.1281561493191237, 0.5980067970163337, -0.2891812666523367, -1.4368957426101734, -0.43331370482237264, 0.5569142619061638, -0.8671123265873902, 0.9729802400008496, 0.2385314434733128])
# output
```
"
@kwdef struct HierarchicalNormal{R <: Real, D <: Sampleable} <: AbstractTuringLatentModel
    "Mean of the normal distribution."
    mean::R = 0.0
    "Prior distribution for the standard deviation."
    std_prior::D = truncated(Normal(0, 0.1), 0, Inf)
end

function HierarchicalNormal(std_prior::Distribution)
    return HierarchicalNormal(; std_prior = std_prior)
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

    η_t = obs_model.mean .+ std .* ϵ_t
    return η_t
end
