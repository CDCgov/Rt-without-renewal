@doc raw"
   Record a variable (using the `Turing` `:=` syntax) in the observation model.

    # Fields
    - `model::AbstractTuringObservationModel`: The observation model to dispatch to.
    - `var_name::String`: The variable name to assign the observation to. Defaults to `exp_y_t`.

    # Constructors

    - `RecordExpectedObs(model::AbstractTuringObservationModel)`: Record the expected observation from the model as `exp_y_t`.

    # Examples

    ```julia
    using EpiAware, Turing
    mdl = RecordExpectedObs(NegativeBinomialError())
    gen_obs = generate_observations(mdl, missing, fill(100, 10))
    sample(gen_obs, Prior(), 10)
    ```
"
struct RecordExpectedObs{M <: AbstractTuringObservationModel} <:
       AbstractTuringObservationModel
    model::M
end

@model function EpiAwareBase.generate_observations(model::RecordExpectedObs, y_t, Y_t)
    exp_y_t := Y_t
    @submodel y_t = generate_observations(model.model, y_t, Y_t)
    return y_t
end
