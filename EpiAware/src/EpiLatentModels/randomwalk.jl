@kwdef struct RandomWalk{D <: Sampleable, S <: Sampleable} <: AbstractLatentModel
    init_prior::D = Normal()
    std_prior::S = truncated(Normal(0.0, 0.05), 0.0, Inf)
end

@model function EpiAwareBase.generate_latent(latent_model::RandomWalk, n)
    ϵ_t ~ MvNormal(ones(n))
    σ_RW ~ latent_model.std_prior
    rw_init ~ latent_model.init_prior
    rw = Vector{eltype(ϵ_t)}(undef, n)

    rw[1] = rw_init + σ_RW * ϵ_t[1]
    for t in 2:n
        rw[t] = rw[t - 1] + σ_RW * ϵ_t[t]
    end
    return rw, (; σ_RW, rw_init)
end
