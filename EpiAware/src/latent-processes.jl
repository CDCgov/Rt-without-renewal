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

    rw[1] = σ_RW * ϵ_t[1]
    for t = 2:n
        rw[t] = rw[t-1] + σ_RW * ϵ_t[t]
    end
    return rw, init, (; σ_RW,)
end

"""
    struct LatentProcess{F<:Function}

A struct representing a latent process with its priors.

# Fields
- `latent_process`: The latent process function for a `Turing` model.
- `latent_process_priors`: NamedTuple containing the priors for the latent process.

"""
struct LatentProcess{F<:Function}
    latent_process::F
    latent_process_priors::NamedTuple
end

"""
    random_walk_process(; latent_process_priors = default_rw_priors())

Create a `LatentProcess` struct reflecting a random walk process with optional priors.

# Arguments
- `latent_process_priors`: Optional priors for the random walk process.

# Returns
- `LatentProcess`: A random walk process.

"""
function random_walk_process(; latent_process_priors = default_rw_priors())
    LatentProcess(random_walk, latent_process_priors)
end
