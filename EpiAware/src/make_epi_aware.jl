@model function make_epi_aware(y_t,
        time_steps;
        epi_model::AbstractEpiModel,
        latent_model::AbstractLatentModel,
        observation_model::AbstractObservationModel
)
    #Latent process
    @submodel Z_t, latent_model_aux = generate_latent(
        latent_model,
        time_steps)

    #Transform into infections
    @submodel I_t = generate_latent_infs(epi_model, Z_t)

    #Predictive distribution of ascerted cases
    @submodel generated_y_t, generated_y_t_aux = generate_observations(
        observation_model,
        y_t,
        I_t)

    #Generate quantities
    return (;
        generated_y_t,
        I_t,
        Z_t,
        process_aux = merge(latent_model_aux, generated_y_t_aux))
end

function make_epi_aware(epiproblem::EpiProblem, data)
    y_t = data.y_t
    time_steps = epiproblem.tspan[end] - epiproblem.tspan[1] + 1

    make_epi_aware(y_t,
        time_steps;
        epiproblem.epi_model,
        epiproblem.latent_model,
        epiproblem.observation_model
    )
end
