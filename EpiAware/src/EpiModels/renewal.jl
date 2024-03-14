@doc raw"
Model unobserved/latent infections as due to time-varying Renewal model with reproduction
number ``\mathcal{R}_t`` which is generated by a latent process.

## Mathematical specification

If ``Z_t`` is a realisation of the latent model, then the unobserved/latent infections are
given by

```math
\begin{align}
\mathcal{R}_t &= g(Z_t),\\
I_t &= \mathcal{R}_t \sum_{i=1}^{n-1} I_{t-i} g_i, \qquad t \geq 1, \\
I_t &= g(\hat{I}_0) \exp(r(\mathcal{R}_1) t), \qquad t \leq 0.
\end{align}
```

where ``g`` is a transformation function and the unconstrained initial infections
``\hat{I}_0`` are sampled from a prior distribution, `initialisation_prior` which must
be supplied to the `DirectInfections` constructor. The default `initialisation_prior` is
the standard Normal `Distributions.Normal()`. The discrete generation interval is given by
``g_i``.

``r(\mathcal{R}_1)`` is the exponential growth rate implied by ``\mathcal{R}_1)``
using the implicit relationship between the exponential growth rate and the reproduction
number.

```math
\mathcal{R} \sum_{j \geq 1} g_j \exp(- r j)= 1.
```

## Constructor

`Renewal` can be constructed by passing an `EpiData` object and and subtype of
[`Distributions.Sampleable`](https://juliastats.org/Distributions.jl/latest/types/#Sampleable).

## Example usage with `generate_latent_infs`

`generate_latent_infs` can be used to construct a `Turing` model for the latent infections
conditional on the sample path of a latent process. In this example, we generate a sample
of a white noise latent process.

First, we construct an `Renewal` struct with an `EpiData` object, an initialisation
prior and a transformation function.

```julia
using Distributions, Turing, EpiAware
gen_int = [0.2, 0.3, 0.5]
g = exp

# Create an EpiData object
data = EpiData(gen_int, g)

# Create an Renewal model
renewal_model = Renewal(data = data, initialisation_prior = Normal())
```

Then, we can use `generate_latent_infs` to construct a Turing model for the unobserved
infection generation model set by the type of `direct_inf_model`.

```julia
# Construct a Turing model
Z_t = randn(100) * 0.05
latent_inf = generate_latent_infs(renewal_model, Z_t)
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
@kwdef struct Renewal{S <: Sampleable} <: EpiAwareBase.AbstractEpiModel
    data::EpiData
    initialisation_prior::S = Normal()
end

@doc """
Callable on a `Renewal` struct for compute new incidence based on recent incidence and Rt.

## Mathematical specification

The new incidence is given by

```math
I_t = R_t \\sum_{i=1}^{n-1} I_{t-i} g_i
```

where `I_t` is the new incidence, `R_t` is the reproduction number, `I_{t-i}` is the recent incidence
and `g_i` is the generation interval.

# Arguments
- `recent_incidence`: Array of recent incidence values.
- `Rt`: Reproduction number.

# Returns
- Tuple containing the updated incidence array and the new incidence value.
"""
function (epi_model::Renewal)(recent_incidence, Rt)
    new_incidence = Rt * dot(recent_incidence, epi_model.data.gen_int)
    return ([new_incidence; recent_incidence[1:(epi_model.data.len_gen_int - 1)]],
        new_incidence)
end

"""
Implement the `generate_latent_infs` function for the `Renewal` model.

## Example usage with `Renewal` type of model for unobserved infection process

`generate_latent_infs` can be used to construct a `Turing` model for the latent infections
conditional on the sample path of a latent process. In this example, we generate a sample
of a white noise latent process.

First, we construct an `Renewal` struct with an `EpiData` object, an initialisation
prior and a transformation function.

```julia
using Distributions, Turing, EpiAware
gen_int = [0.2, 0.3, 0.5]
g = exp

# Create an EpiData object
data = EpiData(gen_int, g)

# Create an Renewal model
renewal_model = Renewal(data = data, initialisation_prior = Normal())
```

Then, we can use `generate_latent_infs` to construct a Turing model for the unobserved
infection generation model set by the type of `renewal_model`.

```julia
# Construct a Turing model
Z_t = randn(100) * 0.05
latent_inf = generate_latent_infs(renewal_model, Z_t)
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
@model function generate_latent_infs(epi_model::Renewal, _Rt)
    init_incidence ~ epi_model.initialisation_prior
    I₀ = epi_model.data.transformation(init_incidence)
    Rt = epi_model.data.transformation.(_Rt)

    r_approx = R_to_r(Rt[1], epi_model)
    init = I₀ * [exp(-r_approx * t) for t in 0:(epi_model.data.len_gen_int - 1)]

    I_t, _ = scan(epi_model, init, Rt)
    return I_t
end
