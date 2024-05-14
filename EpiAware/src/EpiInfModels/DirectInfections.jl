@doc raw"
Model unobserved/latent infections as a transformation on a sampled latent process.

## Mathematical specification

If ``Z_t`` is a realisation of the latent model, then the unobserved/latent infections are
given by

```math
I_t = g(\hat{I}_0 + Z_t).
```

where ``g`` is a transformation function and the unconstrained initial infections
    ``\hat{I}_0`` are sampled from a prior distribution.

`DirectInfections` are constructed by passing an `EpiData` object `data` and an
`initialisation_prior` for the prior distribution of ``\hat{I}_0``. The default
`initialisation_prior` is `Normal()`.

## Constructors

- `DirectInfections(; data, initialisation_prior)`

## Example usage with `generate_infections`

`generate_infections` can be used to construct a `Turing` model for the latent infections
conditional on the sample path of a latent process. In this example, we generate a sample
of a white noise latent process.

First, we construct a `DirectInfections` struct with an `EpiData` object, an initialisation
prior and a transformation function.

```julia
using Distributions, Turing, EpiAware
gen_int = [0.2, 0.3, 0.5]
g = exp

# Create an EpiData object
data = EpiData(gen_int, g)

# Create a DirectInfections model
direct_inf_model = DirectInfections(data = data, initialisation_prior = Normal())
```

Then, we can use `generate_infections` to construct a Turing model for the unobserved
infection generation model set by the type of `direct_inf_model`.

```julia
# Construct a Turing model
Z_t = randn(100)
latent_inf = generate_infections(direct_inf_model, Z_t)
```

Now we can use the `Turing` PPL API to sample underlying parameters and generate the
unobserved infections.

```julia
# Sample from the unobserved infections model

#Sample random parameters from prior
θ = rand(latent_inf)
#Get unobserved infections as a generated quantities from the model
I_t = generated_quantities(latent_inf, θ)
```

"
@kwdef struct DirectInfections{S <: Sampleable, M::AbstractTuringLatentModel, F::Function} <: AbstractTuringEpiModel
    "`Epidata` object."
    data::EpiData
    latent_model::M = Intercept()
    transformation::F = exp
end

"""
Implement the `generate_infections` function for the `DirectInfections` model.

## Example usage with `DirectInfections` type of model for unobserved infection process

First, we construct a `DirectInfections` struct with an `EpiData` object, an initialisation
prior and a transformation function.

```julia
using Distributions, Turing, EpiAware
gen_int = [0.2, 0.3, 0.5]
g = exp

# Create an EpiData object
data = EpiData(gen_int, g)

# Create a DirectInfections model
direct_inf_model = DirectInfections(data = data, latent_model = RandomWalk())
```

Then, we can use `generate_infections` to construct a Turing model for the unobserved
infection generation model set by the type of `direct_inf_model`.

```julia
# Construct a Turing model
latent_inf = generate_infections(direct_inf_model, 20)
```
Now we can use the `Turing` PPL API to sample underlying parameters and generate the
unobserved infections.
```julia
# Sample from the unobserved infections model

#Sample random parameters from prior
θ = rand(latent_inf)
#Get unobserved infections as a generated quantities from the model
I_t = generated_quantities(latent_inf, θ)
```
"""
@model function EpiAwareBase.generate_infections(epi_model::DirectInfections, n)
    @submodel untrans_inf, inf_aux = generate_latent(epi_model.latent_model, n)
    inf = epi_model.data.transformation.(untrans_inf)
    return inf, (; inf_aux)
end
