@doc raw"
The autoregressive (AR) model struct.
"
@with_kw struct AR{D <: Priors, S <: Distribution, I <: Priors} <: AbstractLatentModel
    damp_prior::D = truncated(Normal(0.0, 0.05), 0.0, 1)
    std_prior::S = truncated(Normal(0.0, 0.05), 0.0, Inf)
    init_prior::I = Normal()
    @assert length(damp_prior)==length(init_prior) "damp_prior and init_prior must have the same length"
end

@doc raw"
Generate a latent AR series.

# Arguments

- `latent_model::AR`: The AR model.
- `n::Int`: The length of the AR series.

# Returns
- `ar::Vector{Float64}`: The generated AR series.
- `params::NamedTuple`: A named tuple containing the generated parameters (`σ_AR`, `ar_init`, `damp_AR`).

# Notes
- The length of `damp_prior` and `init_prior` must be the same.
- `n` must be longer than the order of the autoregressive process.
"
@model function EpiAwareBase.generate_latent(latent_model::AR, n)
    p = length(latent_model.damp_prior)
    ϵ_t ~ MvNormal(ones(n - p))
    σ_AR ~ latent_model.std_prior
    ar_init ~ latent_model.init_prior
    damp_AR ~ latent_model.damp_prior

    @assert n>p "n must be longer than order of the autoregressive process"

    # Initialize the AR series with the initial values
    ar = Vector{Float64}(undef, n)
    ar[1:p] = ar_init

    # Generate the rest of the AR series
    for t in (p + 1):n
        ar[t] = damp_AR' * ar[(t - p):(t - 1)] + σ_AR * ϵ_t[t - p]
    end

    return ar, (; σ_AR, ar_init, damp_AR)
end
