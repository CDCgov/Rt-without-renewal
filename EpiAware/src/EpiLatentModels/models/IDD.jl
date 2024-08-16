@doc raw"
Model latent process ``\epsilon_t`` as independent and identically distributed random variables.

## Mathematical specification

The IDD process ``\epsilon_t`` is specified as a sequence of independent and identically distributed random variables,

```math
\epsilon_t \sim \text{Prior}, \quad t = 1, 2, \ldots
```

where Prior is the specified distribution.

## Constructors

- `IDD(prior::Distribution = Normal(0, 1))`: Create an IDD model with the specified prior distribution.

## Examples

```jldoctest IDD; filter =  r\"\b\d+(\.\d+)?\b\" => \"*\"
using EpiAware, Distributions

model = IDD(Normal(0, 1))
# output
IDD{Normal{Float64}}(ϵ_t = Normal{Float64}(μ=0.0, σ=1.0))

```

```jldoctest IDD; filter =  r\"\b\d+(\.\d+)?\b\" => \"*\"
idd = generate_latent(model, 10)
idd()
# output

```
"
@kwdef struct IDD{D <: Sampleable} <: AbstractTuringLatentModel
    ϵ_t::D = Normal(0, 1)
end

@doc raw"
 Generate latent variables from the IDD (Independent and Identically Distributed) model.

# Arguments
- `model::IDD`: The IDD model.
- `n`: Number of latent variables to generate.

# Returns
- `ϵ_t`: Generated latent variables.
"
@model function EpiAwareBase.generate_latent(model::IDD, n)
    ϵ_t ~ filldist(model.ϵ_t, n)
    return ϵ_t
end
