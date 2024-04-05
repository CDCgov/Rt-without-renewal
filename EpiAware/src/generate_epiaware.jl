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
@model function EpiAwareBase.generate_epiware(
        y_t, time_steps; epi_model::AbstractTuringEpiModel,
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
