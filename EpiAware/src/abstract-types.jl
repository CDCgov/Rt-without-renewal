abstract type AbstractModel end

abstract type AbstractEpiModel <: AbstractModel end

abstract type AbstractLatentModel <: AbstractModel end

abstract type AbstractObservationModel <: AbstractModel end

function generate_latent_infs(epi_model::AbstractEpiModel, latent_model)
    @info "No concrete implementation for `generate_latent_infs` is defined."
    return nothing
end

function generate_latent(latent_model::AbstractLatentModel, n)
    @info "No concrete implementation for generate_latent is defined."
    return nothing
end
