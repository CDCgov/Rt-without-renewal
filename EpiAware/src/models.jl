@model function make_epi_inference_model(
        y_t,
        epimodel::AbstractEpiModel,
        latent_process_mdl::AbstractLatentProcess,
        observation_process_obj::ObservationModel;
        pos_shift = 1e-6
)
    #Latent process
    time_steps = epimodel.data.time_horizon
    @submodel latent_process, latent_process_aux = generate_latent_process(
        latent_process_mdl,
        time_steps
    )

    #Transform into infections
    I_t = generate_latent_infs(epimodel, latent_process, log(1.0))

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
