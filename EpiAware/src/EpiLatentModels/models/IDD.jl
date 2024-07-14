@kwdef struct IDD{D <: Samplable} <: AbstractTuringLatentModel
    prior::D = Normal()
end

@model function EpiAwareBase.generate_latent(model::IDD, n)
    ϵ_t ~ filldist(model.prior, n)
    return ϵ_t
end
