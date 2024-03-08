struct ExpGrowthRate{S <: Sampleable} <: AbstractEpiModel
    data::EpiData
    initialisation_prior::S
end

@model function generate_latent_infs(epi_model::ExpGrowthRate, rt)
    init_incidence ~ epi_model.initialisation_prior
    return exp.(init_incidence .+ cumsum(rt))
end
