@kwdef struct AR{D <: Priors, S <: Distribution, I <: Priors, P <: Int}
    """A distribution representing the prior distribution of the damping factors."""
    damp_prior::D = [truncated(Normal(0.0, 0.05), 0.0, 1)]

    """A distribution representing the prior distribution of the variance."""
    var_prior::S = truncated(Normal(0.0, 0.05), 0.0, Inf)

    """A distribution representing the prior distribution of the initial values."""
    init_prior::I = Normal()

    """
    The order of the AR process, determined by the length of `damp_prior`.
    """
    p::P = length(damp_prior)
end

@model function generate_latent(latent_model::AR, n)
    p = latent_model.p
    ϵ_t ~ MvNormal(ones(n - p))
    σ²_AR ~ latent_model.var_prior
    ar_init ~ latent_model.init_prior
    damp_AR ~ latent_model.damp_prior
    σ_AR = sqrt(σ²_AR)

    @assert n>p "n must be longer than latent_model.p"

    # Initialize the AR series with the initial values
    ar = Vector{Float64}(undef, n)
    ar[1:p] = ar_init

    # Generate the rest of the AR series
    for t in (p + 1):n
        ar[t] = damp_AR' * ar[(t - p):(t - 1)] + σ_AR * ϵ_t[t - p]
    end

    return ar, (; σ_AR, ar_init, damp_AR)
end
