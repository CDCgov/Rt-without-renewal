@doc raw"
The `Ascertainment` struct represents an observation model that incorporates ascertainment bias. It is parametrized by two types: `M` which represents the underlying observation model, and `T` which represents the latent model.

# Constructors
- `Ascertainment(model::M, latentmodel::T; link::F = exp) where {M <: AbstractObservationModel, T <: AbstractLatentModel, F <: Function}`: Constructs a new `Ascertainment` object with the specified `model`, `latentmodel`, and `link` function. `link` is a named keyword and defaults to `exp`.
- `Ascertainment(model::M, latentmodel::T, link::F = exp) where {M <: AbstractObservationModel, T <: AbstractLatentModel, F <: Function}`: Constructs a new `Ascertainment` object with the specified `model`, `latentmodel`, and `link` function.

# Examples
```julia
using EpiAware, Turing

struct Scale <: AbstractLatentModel
end

@model function EpiAware.generate_latent(model::Scale, n::Int)
    scale ~ filldist(Normal(0.1, 0.001), n)
    return scale
end

obs = Ascertainment(NegativeBinomialError(), Scale(), x -> x)
gen_obs = generate_observations(obs, missing, [1:10])
rand(gen_obs)
```
"
@kwdef struct Ascertainment{
    M <: AbstractObservationModel, T <: AbstractLatentModel, F <: Function} <:
              AbstractObservationModel
    "The underlying observation model."
    model::M
    "The latent model."
    latentmodel::T
    "The link function used to transform the latent model to the observed data."
    link::F = exp
end

@doc raw"
Generates observations based on the `LatentDelay` observation model.

## Arguments
- `obs_model::Ascertainment`: The Ascertainment model.
- `y_t`: The current state of the observations.
- `Y_t`` : The expected observations.

## Returns
- `y_t`: The updated observations.
- `expected_aux`: Additional expected observation-related variables.
- `obs_aux`: Additional observation-related variables.
"
@model function EpiAwareBase.generate_observations(obs_model::Ascertainment, y_t, Y_t)
    @submodel expected_obs_mod, expected_aux = generate_latent(
        obs_model.latentmodel, length(Y_t))

    expected_obs = Y_t .* obs_model.link(expected_obs_mod)

    @submodel y_t, obs_aux = generate_observations(obs_model.model, y_t, expected_obs)

    return y_t, (; expected_aux..., obs_aux...)
end
