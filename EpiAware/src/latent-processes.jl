function default_rw_priors()
    return (
        var_RW_dist = truncated(Normal(0.0, 0.05), 0.0, Inf),
        init_rw_value_dist = Normal(),
    )
end

@model function random_walk(n; latent_process_priors = default_rw_priors())
    ϵ_t ~ MvNormal(ones(n))
    σ²_RW ~ latent_process_priors.var_RW_dist
    init ~ latent_process_priors.init_rw_value_dist
    σ_RW = sqrt(σ²_RW)
    rw = Vector{eltype(ϵ_t)}(undef, n)

    # rw = σ_RW * cumsum(ϵ_t)
    rw[1] = σ_RW * ϵ_t[1]
    for t = 2:n
        rw[t] = rw[t-1] + σ_RW * ϵ_t[t]
    end
    return rw, (; σ_RW, init)
end
