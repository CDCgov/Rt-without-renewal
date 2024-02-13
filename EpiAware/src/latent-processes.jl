const STANDARD_RW_PRIORS =
    (var_RW_dist = truncated(Normal(0.0, 0.05), 0.0, Inf), init_rw_value_dist = Normal())

@model function random_walk(
    n,
    ϵ_t = missing,
    ::Type{T} = Float64;
    latent_process_priors = STANDARD_RW_PRIORS,
) where {T<:Real}
    rw = Vector{T}(undef, n)
    ϵ_t ~ MvNormal(ones(n))
    σ²_RW ~ latent_process_priors.var_RW_dist
    init_rw_value ~ latent_process_priors.init_rw_value_dist
    σ_RW = sqrt(σ²_RW)
    rw .= init_rw_value .+ cumsum(σ_RW * ϵ_t)
    return rw, (; σ_RW, init_rw_value, init = rw[1])
end
