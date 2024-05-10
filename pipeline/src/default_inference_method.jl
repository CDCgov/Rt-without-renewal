"""
Constructs a default inference method.

# Arguments
- `max_threads::Integer`: The maximum number of threads to use for multi-threaded
    parallel computation, this also sets the number of chains. Default is
    maximum is 10.
- `ndraws::Integer`: The number of draws to generate from the posterior
    distribution. Default is 2000.
- `mcmc_ensemble::AbstractMCMC.AbstractMCMCEnsemble`: The MCMC ensemble to use
    for parallel sampling. Default is MCMCThreads().
- `nruns_pthf::Integer`: The number of runs for the pre-sampler ManyPathfinder.
    Default is 4.
- `maxiters_pthf::Integer`: The maximum number of iterations for the pre-sampler
    ManyPathfinder. Default is 100.

# Returns
- An `EpiMethod` object representing the default inference method.

"""
function default_inference_method(; max_threads::Integer = 10, ndraws::Integer = 2000,
        mcmc_ensemble::AbstractMCMC.AbstractMCMCEnsemble = MCMCThreads(),
        nruns_pthf::Integer = 4, maxiters_pthf::Integer = 100)
    num_threads = min(max_threads, Threads.nthreads())

    return EpiMethod(
        pre_sampler_steps = [ManyPathfinder(nruns = nruns_pthf, maxiters = maxiters_pthf)],
        sampler = NUTSampler(adtype = AutoForwardDiff(),
            ndraws = ndraws,
            nchains = num_threads,
            mcmc_parallel = mcmc_ensemble)
    )
end
