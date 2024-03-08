struct DirectInfections{S <: Sampleable} <: AbstractEpiModel
    data::EpiData
    initialisation_prior::S
end

@model function generate_latent_infs(epi_model::DirectInfections, _It)
    init_incidence ~ epi_model.initialisation_prior
    return epi_model.data.transformation.(init_incidence .+ _It)
end
