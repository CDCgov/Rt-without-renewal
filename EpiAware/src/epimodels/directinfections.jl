@doc raw"
Defines the model for latent infections as a transformation on a sampled latent model.

## Mathematical specification

If ``Z_t`` is a realisation of the latent model, then the latent infections are given by

```math
I_t = g(Z_t).
```

where ``g`` is a transformation function.

## Constructor

`DirectInfections` can be constructed by passing an `EpiData` object and and subtype of
[`Distributions.Sampleable`](https://juliastats.org/Distributions.jl/latest/types/#Sampleable).

## Example usage with `generate_latent_infs`

Create a Turing model for the latent infections conditional on the sample path of a white
    noise latent process.

```julia
using Distributions, Turing, EpiAware
gen_int = [0.2, 0.3, 0.5]
transformation = exp

# Create an EpiData object
data = EpiData(gen_int, transformation)

# Create a DirectInfections model
direct_inf_model = DirectInfections(data = data, initialisation_prior = Normal())

# Generate latent infections
Z_t = randn(100)
latent_inf = generate_latent_infs(direct_inf_model, Z_t)
```
"
@kwdef struct DirectInfections{S <: Sampleable} <: AbstractEpiModel
    "`Epidata`` object."
    data::EpiData
    "Prior distribution for the initialisation of the infections. Default is `Normal()`."
    initialisation_prior::S = Normal()
end

"""
Generate latent infections based on the given epidemiological model and noise term.
"""
@model function generate_latent_infs(epi_model::DirectInfections, Z_t)
    init_incidence ~ epi_model.initialisation_prior
    return epi_model.data.transformation.(init_incidence .+ Z_t)
end
