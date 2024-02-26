@model function make_epi_inference_model(
        y_t,
        time_steps;
        epimodel::AbstractEpiModel,
        initialisation_model::AbstractInitialisation,
        latent_process_model::AbstractLatentProcess,
        observation_model::AbstractObservationModel,
        pos_shift = 1e-6
)
    #Latent process
    @submodel latent_process, latent_process_aux = generate_latent_process(
        latent_process_model,
        time_steps
    )

    #Initialisation
    @submodel _I0, initialisation_aux = generate_initialisation(initialisation_model)

    #Transform into infections
    I_t = generate_latent_infs(epimodel, latent_process, _I0)

    #Predictive distribution of ascerted cases
    @submodel generated_y_t, generated_y_t_aux = generate_observations(
        observation_model,
        y_t,
        I_t;
        pos_shift = pos_shift
    )

    #Generate quantities
    return (;
        generated_y_t,
        I_t,
        latent_process,
        process_aux = merge(latent_process_aux, generated_y_t_aux)
    )
end
