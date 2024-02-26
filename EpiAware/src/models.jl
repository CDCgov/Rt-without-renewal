@model function make_epi_inference_model(
        y_t,
        epimodel::AbstractEpiModel,
        latent_process_obj::LatentProcess,
        observation_process_obj::ObservationModel;
        pos_shift = 1e-6
)
    #Latent process
    time_steps = epimodel.data.time_horizon
    @submodel latent_process, init, latent_process_aux = latent_process_obj.latent_process(
        time_steps;
        latent_process_obj.latent_process_priors...
    )

    #Transform into infections
    I_t = generate_latent_infs(epimodel, latent_process, init)

    #Predictive distribution of ascerted cases
    @submodel generated_y_t, generated_y_t_aux = observation_process_obj.observation_model(
        y_t,
        I_t,
        epimodel::AbstractEpiModel;
        pos_shift = pos_shift,
        observation_process_obj.observation_model_priors...
    )

    #Generate quantities
    return (;
        generated_y_t,
        I_t,
        latent_process,
        process_aux = merge(latent_process_aux, generated_y_t_aux)
    )
end
