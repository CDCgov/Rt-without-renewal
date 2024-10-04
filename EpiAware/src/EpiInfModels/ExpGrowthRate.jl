@doc raw"
Model unobserved/latent infections as due to time-varying exponential growth rate ``r_t``
which is generated by a latent process.

## Mathematical specification

If ``Z_t`` is a realisation of the latent model, then the unobserved/latent infections are
given by

```math
I_t = g(\hat{I}_0) \exp(Z_t).
```

where ``g`` is a transformation function and the unconstrained initial infections
    ``\hat{I}_0`` are sampled from a prior distribution.

`ExpGrowthRate` are constructed by passing an `EpiData` object `data` and an
`initialisation_prior` for the prior distribution of ``\hat{I}_0``. The default
`initialisation_prior` is `Normal()`.

## Constructor

- `ExpGrowthRate(; data, initialisation_prior)`.

## Example usage with `generate_latent_infs`

`generate_latent_infs` can be used to construct a `Turing` model for the latent infections
conditional on the sample path of a latent process. In this example, we generate a sample
of a white noise latent process.

First, we construct an `ExpGrowthRate` struct with an `EpiData` object, an initialisation
prior and a transformation function.

```julia
using Distributions, Turing, EpiAware
gen_int = [0.2, 0.3, 0.5]
g = exp

# Create an EpiData object
data = EpiData(gen_int, g)

# Create an ExpGrowthRate model
exp_growth_model = ExpGrowthRate(data = data, initialisation_prior = Normal())
```

Then, we can use `generate_latent_infs` to construct a Turing model for the unobserved
infection generation model set by the type of `direct_inf_model`.

```julia
# Construct a Turing model
Z_t = randn(100) * 0.05
latent_inf = generate_latent_infs(exp_growth_model, Z_t)
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
@kwdef struct ExpGrowthRate{S <: Sampleable} <: AbstractTuringEpiModel
    data::EpiData
    initialisation_prior::S = Normal()
end

@doc raw"
Implement the `generate_latent_infs` function for the `ExpGrowthRate` model.

## Example usage with `ExpGrowthRate` type of model for unobserved infection process

`generate_latent_infs` can be used to construct a `Turing` model for the latent infections
conditional on the sample path of a latent process. In this example, we generate a sample
of a white noise latent process.

First, we construct an `ExpGrowthRate` struct with an `EpiData` object, an initialisation
prior and a transformation function.

```julia
using Distributions, Turing, EpiAware
gen_int = [0.2, 0.3, 0.5]
g = exp

# Create an EpiData object
data = EpiData(gen_int, g)

# Create an ExpGrowthRate model
exp_growth_model = ExpGrowthRate(data = data, initialisation_prior = Normal())
```

Then, we can use `generate_latent_infs` to construct a Turing model for the unobserved
infection generation model set by the type of `direct_inf_model`.

```julia
# Construct a Turing model
Z_t = randn(100) * 0.05
latent_inf = generate_latent_infs(exp_growth_model, Z_t)
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
@model function EpiAwareBase.generate_latent_infs(epi_model::ExpGrowthRate, rt)
    init_incidence ~ epi_model.initialisation_prior
    return exp.(accumulate(+, rt; init=init_incidence))
end
