function generate_latent(latent_model::AbstractLatentModel, n)
    @info "No concrete implementation for generate_latent is defined."
    return nothing
end

struct RandomWalk{D <: Sampleable, S <: Sampleable} <: AbstractLatentModel
    init_prior::D
    std_prior::S
end

function default_rw_priors()
    return (:var_RW_prior => truncated(Normal(0.0, 0.05), 0.0, Inf),
        :init_rw_value_prior => Normal()) |> Dict
end

@model function generate_latent(latent_model::RandomWalk, n)
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

struct AR <: AbstractLatentModel
    """A distribution, a vector of distributions, or a product of distributions representing the prior distributions of the damping factors."""
    damp_prior::Union{Distribution, Vector{<:Distribution}, Product}

    """A distribution representing the prior distribution of the variance."""
    var_prior::Distribution

    """A distribution, a vector of distributions, or a product of distributions representing the prior distributions of the initial values."""
    init_prior::Union{Distribution, Vector{<:Distribution}, Product}

    """
    The order of the AR process, determined by the length of `damp_prior`.
    """
    p::Int

    function AR(damp_prior::Union{Distribution, Vector{<:Distribution}, Product},
            var_prior::Distribution,
            init_prior::Union{Distribution, Vector{<:Distribution}, Product})
        p = length(damp_prior)
        @assert length(init_prior)==p "Dimension of init_prior must be equal to the order of the AR process"
        return new(damp_prior, var_prior, init_prior, p)
    end
end

function default_ar_priors()
    return (:damp_prior => [truncated(Normal(0.0, 0.05), 0.0, 1)],
        :var_prior => truncated(Normal(0.0, 0.05), 0.0, Inf),
        :init_prior => Normal()) |> Dict
end

@model function generate_latent(latent_model::AR, n)
    p = latent_model.p
    ϵ_t ~ MvNormal(ones(n - p))
    σ²_AR ~ latent_model.var_prior
    ar_init ~ latent_model.init_prior
    damp_AR ~ latent_model.damp_prior
    σ_AR = sqrt(σ²_AR)

    @assert n>p "n must be longer than p"

    # Initialize the AR series with the initial values
    ar = Vector{Float64}(undef, n)
    ar[1:p] = ar_init

    # Generate the rest of the AR series
    for t in (p + 1):n
        ar[t] = damp_AR' * ar[(t - p):(t - 1)] + σ_AR * ϵ_t[t - p]
    end

    return ar, (; σ_AR, ar_init, damp_AR)
end
