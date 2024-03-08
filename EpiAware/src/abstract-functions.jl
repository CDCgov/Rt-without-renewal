function generate_latent(latent_model::AbstractLatentModel, n)
    @info "No concrete implementation for generate_latent is defined."
    return nothing
end

function generate_latent_infs(epi_model::AbstractEpiModel, latent_model)
    @info "No concrete implementation for `generate_latent_infs` is defined."
    return nothing
end

function generate_observations(observation_model::AbstractObservationModel,
        y_t,
        I_t;
        pos_shift)
    @info "No concrete implementation for generate_observations is defined."
    return nothing
end
