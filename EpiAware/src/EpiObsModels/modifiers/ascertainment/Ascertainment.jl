@doc raw"
The `Ascertainment` struct represents an observation model that incorporates a ascertainment model. If a `latent_prefix`is supplied the `latent_model` is wrapped in a call to `PrefixLatentModel`.

# Constructors
- `Ascertainment(model::M, latent_model::T, link::F, latent_prefix::P) where {M <: AbstractTuringObservationModel, T <: AbstractTuringLatentModel, F <: Function, P <: String}`: Constructs an `Ascertainment` instance with the specified observation model, latent model, link function, and latent prefix.
- `Ascertainment(; model::M, latent_model::T, link::F, latent_prefix::P) where {M <: AbstractTuringObservationModel, T <: AbstractTuringLatentModel, F <: Function, P <: String}`: Constructs an `Ascertainment` instance with the specified observation model, latent model, link function, and latent prefix.

# Examples
```julia
using EpiAware, Turing
obs = Ascertainment(model = NegativeBinomialError(), latent_model = FixedIntercept(0.1))
gen_obs = generate_observations(obs, missing, fill(100, 10))
rand(gen_obs)
```
"
struct Ascertainment{
    M <: AbstractTuringObservationModel, T <: AbstractTuringLatentModel,
    F <: Function, P <: String} <: AbstractTuringObservationModel
    "The underlying observation model."
    model::M
    "The latent model."
    latent_model::T
    "The link function used to transform the latent model to the observed data."
    link::F
    latent_prefix::P

    function Ascertainment(model::M,
            latent_model::T,
            link::F,
            latent_prefix::P) where {
            M <: AbstractTuringObservationModel, T <: AbstractTuringLatentModel,
            F <: Function, P <: String}
        prefix_model = if latent_prefix == ""
            latent_model
        else
            PrefixLatentModel(latent_model, latent_prefix)
        end
        return new{M, AbstractTuringLatentModel, F, P}(
            model, prefix_model, link, latent_prefix)
    end

    function Ascertainment(model::M,
            latent_model::T;
            link::F = x -> exp.(x),
            latent_prefix::P = "Ascertainment") where {
            M <: AbstractTuringObservationModel, T <: AbstractTuringLatentModel,
            F <: Function, P <: String}
        return Ascertainment(model, latent_model, link, latent_prefix)
    end

    function Ascertainment(; model::M,
            latent_model::T,
            link::F = x -> exp.(x),
            latent_prefix::P = "Ascertainment") where {
            M <: AbstractTuringObservationModel, T <: AbstractTuringLatentModel,
            F <: Function, P <: String}
        return Ascertainment(model, latent_model, link, latent_prefix)
    end
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
        obs_model.latent_model, length(Y_t))

    expected_obs = Y_t .* obs_model.link(expected_obs_mod)

    @submodel y_t, obs_aux = generate_observations(obs_model.model, y_t, expected_obs)
    return y_t, (; expected_obs, expected_obs_mod, expected_aux..., obs_aux...)
end
