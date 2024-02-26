abstract type AbstractLatentProcess end

struct RandomWalkLatentProcess{D <: Sampleable, S <: Sampleable} <: AbstractLatentProcess
    init_prior::D
    var_prior::S
end

function default_rw_priors()
    return (
        :var_RW_prior => truncated(Normal(0.0, 0.05), 0.0, Inf),
        :init_rw_value_prior => Normal()
    ) |> Dict
end

@model function generate_latent_process(latent_process::AbstractLatentProcess, n; kwargs...)
    @info "No concrete implementation for generate_latent_process is defined."
end

@model function generate_latent_process(latent_process::RandomWalkLatentProcess, n)
    ϵ_t ~ MvNormal(ones(n))
    σ²_RW ~ latent_process.var_prior
    rw_init ~ latent_process.init_prior
    σ_RW = sqrt(σ²_RW)
    rw = Vector{eltype(ϵ_t)}(undef, n)

    rw[1] = rw_init + σ_RW * ϵ_t[1]
    for t in 2:n
        rw[t] = rw[t - 1] + σ_RW * ϵ_t[t]
    end
    return rw, (; σ_RW, rw_init)
end

# function random_walk_process(; latent_process_priors = default_rw_priors())
#     LatentProcess(random_walk, latent_process_priors)
# end
