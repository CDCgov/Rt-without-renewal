abstract type AbstractLatentProcess end
abstract type AbstractLatentProcessArg end

struct RandomWalkLatentProcess{D <: Sampleable, S <: Sampleable} <: AbstractLatentProcess
    init_prior::D
    var_prior::S
end

struct RandomWalkLatentProcessArg <: AbstractLatentProcessArg end

function default_rw_priors()
    return (:var_RW_prior => truncated(Normal(0.0, 0.05), 0.0, Inf),
        :init_rw_value_prior => Normal()) |> Dict
end

function latent_process(lp::AbstractLatentProcess, n;
        kwargs...)
    return latent_process(
        AbstractLatentProcessArg(), n; var_prior = lp.var_prior, init_prior = lp.init_prior)
end

function latent_process(lp::AbstractLatentProcess, n; kwargs...)
    @info "No concrete implementation for latent_process is defined."
    return nothing
end

function latent_process(lp::RandomWalkLatentProcess, n)
    return latent_process(
        RandomWalkLatentProcessArg(), n; var_prior = lp.var_prior,
        init_prior = lp.init_prior
    )
end

@model function latent_process(lp::RandomWalkLatentProcessArg, n;
        var_prior::ContinuousDistribution, init_prior::ContinuousDistribution)
    ϵ_t ~ MvNormal(ones(n))
    σ²_RW ~ var_prior
    rw_init ~ init_prior
    σ_RW = sqrt(σ²_RW)
    rw = Vector{eltype(ϵ_t)}(undef, n)

    rw[1] = rw_init + σ_RW * ϵ_t[1]
    for t in 2:n
        rw[t] = rw[t - 1] + σ_RW * ϵ_t[t]
    end
    return rw, (; σ_RW, rw_init)
end
