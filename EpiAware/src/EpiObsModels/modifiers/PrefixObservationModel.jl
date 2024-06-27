@doc raw"
    Generate an observation model with a prefix. A lightweight wrapper around `EpiAwareUtils.prefix_submodel`.

    # Constructors
    - `PrefixObservationModel(model::M, prefix::P)`: Create a `PrefixObservationModel` with the observation model `model` and the prefix `prefix`.
    - `PrefixObservationModel(; model::M, prefix::P)`: Create a `PrefixObservationModel` with the observation model `model` and the prefix `prefix`.

    # Examples
    ```julia
    using EpiAware
    observation_model = PrefixObservationModel(Poisson(), \"Test\")
    obs = generate_observations(observation_model, 10)
    rand(obs)
    ```
"
@kwdef struct PrefixObservationModel{M <: AbstractTuringObservationModel, P <: String} <:
              AbstractTuringObservationModel
    "The observation model"
    model::M
    "The prefix for the observation model"
    prefix::P
end

@model function EpiAwareBase.generate_observations(
        observation_model::PrefixObservationModel, y_t, Y_t)
    @submodel submodel = prefix_submodel(
        observation_model.model, generate_observations, observation_model.prefix, y_t, Y_t)
    return submodel
end
