struct AR <: AbstractLatentModel
    """A distribution representing the prior distribution of the damping factors."""
    damp_prior::Priors

    """A distribution representing the prior distribution of the variance."""
    var_prior::Distribution

    """A distribution representing the prior distribution of the initial values."""
    init_prior::Priors

    """
    The order of the AR process, determined by the length of `damp_prior`.
    """
    p::Int

    function AR(damp_prior::Priors, var_prior::Distribution, init_prior::Priors)
        p = length(damp_prior)
        return AR(damp_prior, var_prior, init_prior, p)
    end

    function AR(damp_prior::Priors, var_prior::Distribution, init_prior::Priors, p::Int)
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
