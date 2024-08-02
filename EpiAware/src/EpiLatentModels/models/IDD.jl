@kwdef struct IDD{D <: Sampleable} <: AbstractTuringLatentModel
    prior::D = Normal(0, 1)
end

@model function EpiAwareBase.generate_latent(model::IDD, n)
    ϵ_t ~ filldist(model.prior, n)
    return ϵ_t
end
