@doc raw"
The `Ascertainment` struct represents an observation model that incorporates ascertainment bias. It is parametrized by two types: `M` which represents the underlying observation model, and `T` which represents the latent model.

# Constructors
- `Ascertainment(model::M, latentmodel::T; link::F = exp) where {M <: AbstractTuringObservationModel, T <: AbstractTuringLatentModel, F <: Function}`: Constructs a new `Ascertainment` object with the specified `model`, `latentmodel`, and `link` function. `link` is a named keyword and defaults to `exp`.
- `Ascertainment(model::M, latentmodel::T, link::F = exp) where {M <: AbstractTuringObservationModel, T <: AbstractTuringLatentModel, F <: Function}`: Constructs a new `Ascertainment` object with the specified `model`, `latentmodel`, and `link` function.

# Examples
```julia
using EpiAware, Turing

struct Scale <: AbstractTuringLatentModel
end

@model function EpiAware.generate_latent(model::Scale, n::Int)
    scale = 0.1
    scale_vect = fill(scale, n)
    return scale_vect, (; scale = scale)
end

obs = Ascertainment(NegativeBinomialError(), Scale(), x -> x)
gen_obs = generate_observations(obs, missing, fill(100, 10))
rand(gen_obs)
```
"
@kwdef struct Ascertainment{
    M <: AbstractTuringObservationModel, T <: AbstractTuringLatentModel, F <: Function} <:
              AbstractTuringObservationModel
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
    return y_t, (; expected_obs, expected_obs_mod, expected_aux..., obs_aux...)
end
