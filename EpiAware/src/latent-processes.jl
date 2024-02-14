function default_rw_priors()
    return (
        var_RW_dist = truncated(Normal(0.0, 0.05), 0.0, Inf),
        init_rw_value_dist = Normal(),
    )
end

@model function random_walk(
    n,
    ϵ_t = missing,
    ::Type{T} = Float64;
    latent_process_priors = default_rw_priors(),
) where {T<:AbstractFloat}
    rw = Vector{T}(undef, n)
    ϵ_t ~ MvNormal(ones(n))
    σ²_RW ~ latent_process_priors.var_RW_dist
    init_rw_value ~ latent_process_priors.init_rw_value_dist
    σ_RW = sqrt(σ²_RW)

    rw[1] = init_rw_value + σ_RW * ϵ_t[1]
    for t = 2:n
        rw[t] = rw[t-1] + σ_RW * ϵ_t[t]
    end
    return rw, (; σ_RW, init_rw_value, init = rw[1])
end
