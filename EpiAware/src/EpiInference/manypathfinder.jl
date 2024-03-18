"""
A variational inference method that runs `manypathfinder`.
"""
@kwdef struct ManyPathfinderMethod <: AbstractEpiOptMethod
    "Number of many pathfinder runs."
    nruns::Int = 4
    "Maximum number of iterations for each run."
    maxiters::Int = 50
    "Maximum number of tries if all runs fail."
    max_tries::Int = 100
end

"""
Run pathfinder multiple times and store the results in an array. Fails safely.

# Arguments
- `mdl::DynamicPPL.Model`: The `Turing` model to be used for inference.
- `nruns`: The number of times to run the `pathfinder` function.
- `kwargs...`: Additional keyword arguments passed to `pathfinder`.

# Returns
An array of `PathfinderResult` objects or `Symbol` values indicating success or failure.
"""
function _run_manypathfinder(mdl::DynamicPPL.Model; nruns, kwargs...)
    @info "Running pathfinder $nruns times"
    pfs = Vector{Union{PathfinderResult, Symbol}}(undef, nruns)
    Threads.@threads for i in 1:nruns
        try
            pfs[i] = pathfinder(mdl; kwargs...)
        catch
            pfs[i] = :fail
        end
    end
    return pfs
end

"""
Continue running the pathfinder algorithm until a pathfinder succeeds or the maximum number
of tries is reached.

# Arguments
- `pfs`: An array of pathfinder objects.
- `mdl::DynamicPPL.Model`: The model to perform inference on.
- `max_tries`: The maximum number of tries to run the pathfinder algorithm. Default is
    `Inf`.
- `nruns`: The number of times to run the `pathfinder` function.
- `kwargs...`: Additional keyword arguments passed to `pathfinder`.

# Returns
- `pfs`: The updated array of pathfinder objects.

"""
function _continue_manypathfinder!(pfs, mdl::DynamicPPL.Model; max_tries, nruns, kwargs...)
    tryiter = 1
    if all(pfs .== :fail)
        @warn "All initial pathfinder runs failed, trying again for $max_tries tries."
    end
    while all(pfs .== :fail) && tryiter <= max_tries
        new_pf = try
            pathfinder(mdl; kwargs...)
        catch
            :fail
        end
        pfs = vcat(pfs, new_pf)
        tryiter += 1
    end
    if all(pfs .== :fail)
        e = ErrorException("All pathfinder runs failed after $max_tries tries.")
        throw(e)
    end
    return pfs
end

"""
Selects the pathfinder with the highest ELBO estimate from a list of pathfinders.

# Arguments
- `pfs`: A list of pathfinders results or `Symbol` values indicating failure.

# Returns
The pathfinder with the highest ELBO estimate.
"""
function _get_best_elbo_pathfinder(pfs)
    elbos = map(pfs) do pf_res
        pf_res == :fail ? -Inf : pf_res.elbo_estimates[end].value
    end
    _, choice_of_pf = findmax(elbos)
    return pfs[choice_of_pf]
end

"""
Run multiple instances of the pathfinder algorithm and returns the pathfinder run with the
largest ELBO estimate.

## Arguments
- `mdl::DynamicPPL.Model`: The model to perform inference on.
- `nruns::Int`: The number of pathfinder runs to perform.
- `ndraws::Int`: The number of draws per pathfinder run, readjusted to be at least as large
    as the number of chains.
- `nchains::Int`: The number of chains that will be initialised by pathfinder draws.
- `maxiters::Int`: The maximum number of optimizer iterations per pathfinder run.
- `max_tries::Int`: The maximum number of extra tries to find a valid pathfinder result.
- `kwargs...`: Additional keyword arguments passed to `pathfinder`.

## Returns
- `best_pfs::PathfinderResult`: Best pathfinder result by estimated ELBO.
"""
function manypathfinder(mdl::DynamicPPL.Model, ndraws; nruns = 4,
        maxiters = 50, max_tries = 100, kwargs...)
    _run_manypathfinder(mdl; nruns, ndraws, maxiters, kwargs...) |>
    pfs -> _continue_manypathfinder!(pfs, mdl; max_tries, nruns, kwargs...) |>
           pfs -> _get_best_elbo_pathfinder(pfs)
end
