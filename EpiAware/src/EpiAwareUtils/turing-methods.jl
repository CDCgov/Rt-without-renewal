@doc raw"
Generate an epi-aware model given the observed data and model specifications.

# Arguments
- `y_t`: Observed data.
- `time_steps`: Number of time steps.
- `epi_model`: A Turing Epi model specification.
- `latent_model`: A Turing Latent model specification.
- `observation_model`: A Turing Observation model specification.

# Returns
A `DynamicPPPL.Model` object.
"
@model function EpiAwareBase.generate_epiaware(
        y_t, time_steps, epi_model::AbstractTuringEpiModel,
        latent_model::AbstractTuringLatentModel, observation_model::AbstractTuringObservationModel)
    # Latent process
    @submodel Z_t, latent_model_aux = generate_latent(latent_model, time_steps)

    # Transform into infections
    @submodel I_t = generate_latent_infs(epi_model, Z_t)

    # Predictive distribution of ascertained cases
    @submodel generated_y_t, generated_y_t_aux = generate_observations(
        observation_model, y_t, I_t)

    # Generate quantities
    return (;
        generated_y_t, I_t, Z_t, process_aux = merge(latent_model_aux, generated_y_t_aux))
end

"""
Apply the condition to the model by fixing the specified parameters and conditioning on the others.

# Arguments
- `model::Model`: The model to be conditioned.
- `fix_parameters::NamedTuple`: The parameters to be fixed.
- `condition_parameters::NamedTuple`: The parameters to be conditioned on.

# Returns
- `_model`: The conditioned model.
"""
function EpiAwareBase.condition_model(
        model::Model, fix_parameters::NamedTuple, condition_parameters::NamedTuple)
    _model = fix(model, fix_parameters)
    _model = condition(_model, condition_parameters)
    return _model
end

@doc raw"
Generate observables from a given model and solution including generated quantities.
"
function EpiAwareBase.generate_observables(
        model::Model, solution::Union{Chains, NamedTuple})
    gens = generated_quantities(model, solution)
    (samples = solution, gens = gens, model = model)
end
