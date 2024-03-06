@model function safe_mode_model(model,
        y_t,
        time_steps;
        epi_model::AbstractEpiModel,
        latent_model::AbstractLatentModel,
        observation_model::AbstractObservationModel,
        pos_shift = 1e-6)
    try
        @submodel model(y_t,
            time_steps;
            epi_model = epi_model,
            latent_model = latent_model,
            observation_model = observation_model,
            pos_shift = pos_shift)
    catch
        Turing.@addlogprob! -Inf
        return
    end
end
