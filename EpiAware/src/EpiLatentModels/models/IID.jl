@doc raw"
Model latent process ``\epsilon_t`` as independent and identically distributed random variables.

## Mathematical specification

The IID process ``\epsilon_t`` is specified as a sequence of independent and identically distributed random variables,

```math
\epsilon_t \sim \text{Prior}, \quad t = 1, 2, \ldots
```

where Prior is the specified distribution.

## Constructors

- `IID(prior::Distribution = Normal(0, 1))`: Create an IID model with the specified prior distribution.

## Examples

```jldoctest IID; filter =  r\"\b\d+(\.\d+)?\b\" => \"*\"
using EpiAware, Distributions

model = IID(Normal(0, 1))
# output
IID{Normal{Float64}}(Distributions.Normal{Float64}(μ=0.0, σ=1.0))

```

```jldoctest IID; filter =  r\"\b\d+(\.\d+)?\b\" => \"*\"
idd = generate_latent(model, 10)
idd()
# output
 10-element Vector{Float64}:
│   0.1725470673732349
│  -0.9893774177277903
│  -0.7412779059226116
│  -0.05657055467885716
│   3.472387217534668
│  -1.2172271390889986
│  -0.029909748834874326
│   0.12022293960210076
│   0.3000491076584262
│   0.7071362084677751
```
"
@kwdef struct IID{D <: Sampleable} <: AbstractTuringLatentModel
    ϵ_t::D = Normal(0, 1)
end

@doc raw"
 Generate latent variables from the IID (Independent and Identically Distributed) model.

# Arguments
- `model::IID`: The IID model.
- `n`: Number of latent variables to generate.

# Returns
- `ϵ_t`: Generated latent variables.
"
@model function EpiAwareBase.generate_latent(model::IID, n)
    ϵ_t ~ filldist(model.ϵ_t, n)
    return ϵ_t
end
