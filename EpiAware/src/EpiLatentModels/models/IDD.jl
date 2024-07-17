@kwdef struct IDD{D <: Sampleable} <: AbstractTuringLatentModel
    prior::D = Normal(0, 1)
end

@model function EpiAwareBase.generate_latent(model::IDD, n)
    if __context__.context isa PredictContext
        @info "Predicting"
        ϵ_t = Vector(undef, n)
        for i in eachindex(ϵ_t)
            ϵ_t[i] ~ model.prior
        end
    else
        @info "Not predicting"
        ϵ_t ~ filldist(model.prior, n)
    end
    return ϵ_t
end
