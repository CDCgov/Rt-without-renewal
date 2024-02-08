"""
    random_walk(n, ϵ_t = missing; latent_process_priors = (var_RW_dist = truncated(Normal(0., 0.05), 0., Inf),), ::Type{T} = Float64) where {T <: Real}

Constructs a random walk model.

# Arguments
- `n`: The number of time steps.
- `ϵ_t`: The random noise vector. Defaults to `missing`, in which case it is sampled from the standard multivariate normal distribution.
- `latent_process_priors`: The prior distribution for the latent process parameters. Defaults to `(var_RW_dist = truncated(Normal(0., 0.05), 0., Inf),)`.

# Returns
- `rw`: The random walk process.
- `σ_RW`: The standard deviation of the random walk process.
"""
@model function random_walk(
    n,
    ϵ_t = missing,
    ::Type{T} = Float64;
    latent_process_priors = (var_RW_dist = truncated(Normal(0.0, 0.05), 0.0, Inf),),
) where {T <: Real}
    rw = Vector{T}(undef, n)
    ϵ_t ~ MvNormal(ones(n))
    σ²_RW ~ latent_process_priors.var_RW_dist
    σ_RW = sqrt(σ²_RW)
    rw .= cumsum(σ_RW * ϵ_t)
    return rw, (; σ_RW)
end
