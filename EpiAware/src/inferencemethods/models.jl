@model function make_epi_aware(y_t,
        time_steps;
        epi_model::AbstractEpiModel,
        latent_model::AbstractLatentModel,
        observation_model::AbstractObservationModel,
        pos_shift = 1e-6)
    #Latent process
    @submodel Z_t, latent_model_aux = generate_latent(
        latent_model,
        time_steps)

    #Transform into infections
    @submodel I_t = generate_latent_infs(epi_model, Z_t)

    #Predictive distribution of ascerted cases
    @submodel generated_y_t, generated_y_t_aux = generate_observations(observation_model,
        y_t,
        I_t;
        pos_shift = pos_shift)

    #Generate quantities
    return (;
        generated_y_t,
        I_t,
        latent_model,
        process_aux = merge(latent_model_aux, generated_y_t_aux))
end
