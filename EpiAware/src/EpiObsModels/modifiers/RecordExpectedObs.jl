@doc raw"
   Record a variable (using the `Turing` `:=` syntax) in the observation model.

    # Fields
    - `model::AbstractTuringObservationModel`: The observation model to dispatch to.

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

@doc raw"
Generate observations using a model that records the expected observations.

# Arguments
- `model::RecordExpectedObs`: The recording model.
- `y_t`: The current state of the observations. If missing, a vector of missing values is created.
- `Y_t`: The expected observations.

# Returns
- The observations generated by the underlying model. Additionally records `Y_t` as `exp_y_t`
  using Turing's `:=` syntax.

# Details
This function wraps the underlying observation model's `generate_observations` function and
additionally records the expected observations `Y_t` as `exp_y_t` in the model.
"
@model function EpiAwareBase.generate_observations(model::RecordExpectedObs, y_t, Y_t)
    exp_y_t := Y_t
    @submodel y_t = generate_observations(model.model, y_t, Y_t)
    return y_t
end
