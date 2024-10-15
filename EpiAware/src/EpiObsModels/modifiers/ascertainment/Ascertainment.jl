@doc raw"
The `Ascertainment` struct represents an observation model that incorporates a ascertainment model. If a `latent_prefix`is supplied the `latent_model` is wrapped in a call to `PrefixLatentModel`.

# Constructors
- `Ascertainment(model::M, latent_model::T, transform::F, latent_prefix::P) where {M <: AbstractTuringObservationModel, T <: AbstractTuringLatentModel, F <: Function, P <: String}`: Constructs an `Ascertainment` instance with the specified observation model, latent model, transform function, and latent prefix.
- `Ascertainment(; model::M, latent_model::T, transform::F = (Y_t, x) -> xexpy.(Y_t, x), latent_prefix::P = \"Ascertainment\") where {M <: AbstractTuringObservationModel, T <: AbstractTuringLatentModel, F <: Function, P <: String}`: Constructs an `Ascertainment` instance with the specified observation model, latent model, optional transform function (default: `(Y_t, x) -> xexpy.(Y_t, x)`), and optional latent prefix (default: \"Ascertainment\").

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
    "The function used to transform Y_t and the latent model output."
    transform::F
    latent_prefix::P

    function Ascertainment(model::M,
            latent_model::T,
            transform::F,
            latent_prefix::P) where {
            M <: AbstractTuringObservationModel, T <: AbstractTuringLatentModel,
            F <: Function, P <: String}
        # Check if the transform function takes two arguments
        if !hasmethod(transform, Tuple{<:Vector, <:Vector})
            throw(ArgumentError("The transform function must take two Vector arguments"))
        end
        prefix_model = latent_prefix == "" ? latent_model :
                       PrefixLatentModel(latent_model, latent_prefix)
        return new{M, AbstractTuringLatentModel, F, P}(
            model, prefix_model, transform, latent_prefix)
    end

    function Ascertainment(model::M,
            latent_model::T;
            transform::F = (x, y) -> xexpy.(x, y),
            latent_prefix::P = "Ascertainment") where {
            M <: AbstractTuringObservationModel, T <: AbstractTuringLatentModel,
            F <: Function, P <: String}
        return Ascertainment(model, latent_model, transform, latent_prefix)
    end

    function Ascertainment(; model::M,
            latent_model::T,
            transform::F = (x, y) -> xexpy.(x, y),
            latent_prefix::P = "Ascertainment") where {
            M <: AbstractTuringObservationModel, T <: AbstractTuringLatentModel,
            F <: Function, P <: String}
        return Ascertainment(model, latent_model, transform, latent_prefix)
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
    @submodel expected_obs_mod = generate_latent(
        obs_model.latent_model, length(Y_t)
    )

    expected_obs = obs_model.transform(Y_t, expected_obs_mod)

    @submodel y_t = generate_observations(obs_model.model, y_t, expected_obs)
    return y_t
end
