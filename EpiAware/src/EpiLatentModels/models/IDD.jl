@kwdef struct IDD{D <: Sampleable} <: AbstractTuringLatentModel
    prior::D = Normal()
end

@model function EpiAwareBase.generate_latent(model::IDD, n)
    if __context__.context isa PredictContext
        @info "Predicting"
        ϵ_t = Vector{Float64}(undef, n)
        for i in 1:n
            ϵ_t[i] ~ model.prior
        end
    else
        @info "Generating"
        ϵ_t ~ filldist(model.prior, n)
    end
    return ϵ_t
end
