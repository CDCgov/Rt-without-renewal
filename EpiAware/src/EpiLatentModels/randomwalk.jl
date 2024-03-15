@doc raw"
Model latent process ``Z_t`` as a random walk.

## Mathematical specification

The random walk ``Z_t`` is specified as a parameteric transformation of the white noise
sequence ``(\epsilon_t)_{t\geq 1}``,

```math
Z_t = Z_0 + \sigma \sum_{i = 1}^t \epsilon_t
```

Constructing a random walk requires specifying:
- An `init_prior` as a prior for ``Z_0``. Default is `Normal()`.
- A `std_prior` for ``\sigma``. The default is HalfNormal with a mean of 0.25.

## Constructors

- `RandomWalk(; init_prior, std_prior)`

## Example usage with `generate_latent`

`generate_latent` can be used to construct a `Turing` model for the random walk ``Z_t``.

First, we construct a `RandomWalk` struct with priors,

```julia
using Distributions, Turing, EpiAware

# Create a RandomWalk model
rw = RandomWalk(init_prior = Normal(2., 1.),
                                std_prior = _make_halfnormal_prior(0.1))
```

Then, we can use `generate_latent` to construct a Turing model for a 10 step random walk.

```julia
# Construct a Turing model
rw_model = generate_latent(rw, 10)
```

Now we can use the `Turing` PPL API to sample underlying parameters and generate the
unobserved infections.

```julia
#Sample random parameters from prior
θ = rand(rw_model)
#Get random walk sample path as a generated quantities from the model
Z_t, _ = generated_quantities(rw_model, θ)
```
"
@kwdef struct RandomWalk{D <: Sampleable, S <: Sampleable} <: AbstractLatentModel
    init_prior::D = Normal()
    std_prior::S = _make_halfnormal_prior(0.25)
end

@doc raw"
Implement the `generate_latent` function for the `RandomWalk` model.

## Example usage of `generate_latent` with `RandomWalk` type of latent process model

```julia
using Distributions, Turing, EpiAware

# Create a RandomWalk model
rw = RandomWalk(init_prior = Normal(2., 1.),
                                std_prior = _make_halfnormal_prior(0.1))
```

Then, we can use `generate_latent` to construct a Turing model for a 10 step random walk.

```julia
# Construct a Turing model
rw_model = generate_latent(rw, 10)
```

Now we can use the `Turing` PPL API to sample underlying parameters and generate the
unobserved infections.

```julia
#Sample random parameters from prior
θ = rand(rw_model)
#Get random walk sample path as a generated quantities from the model
Z_t, _ = generated_quantities(rw_model, θ)
```
"
@model function EpiAwareBase.generate_latent(latent_model::RandomWalk, n)
    ϵ_t ~ MvNormal(ones(n))
    σ_RW ~ latent_model.std_prior
    rw_init ~ latent_model.init_prior
    rw = Vector{eltype(ϵ_t)}(undef, n)

    rw[1] = rw_init + σ_RW * ϵ_t[1]
    for t in 2:n
        rw[t] = rw[t - 1] + σ_RW * ϵ_t[t]
    end
    return rw, (; σ_RW, rw_init)
end
