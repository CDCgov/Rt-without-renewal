@doc raw"
Generate an epi-aware model given the observed data and model specifications.

# Arguments
- `y_t`: Observed data.
- `time_steps`: Number of time steps.
- `epi_model`: Epi model specification.
- `latent_model`: Latent model specification.
- `observation_model`: Observation model specification.

# Returns
A `DynamicPPPL.Model` object.
"
@model function make_epi_aware(y_t, time_steps; epi_model::AbstractEpiModel,
        latent_model::AbstractLatentModel, observation_model::AbstractObservationModel)
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

@doc raw"
Generate an epi-aware model given an `EpiProblem` and data.

# Arguments
- `epiproblem`: Epi problem specification.
- `data`: Observed data.

# Returns
A tuple containing the generated quantities of the epi-aware model.
"
function make_epi_aware(epiproblem::EpiProblem, data)
    y_t = data.y_t
    time_steps = epiproblem.tspan[end] - epiproblem.tspan[1] + 1

    make_epi_aware(y_t, time_steps; epiproblem.epi_model,
        epiproblem.latent_model, epiproblem.observation_model)
end
