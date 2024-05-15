"""
Constructs and returns an `EpiMethod` object with default settings for inference.

# Arguments
- `max_threads::Integer`: The maximum number of threads to use for parallelization.
    Default is 10.
- `ndraws::Integer`: The number of MCMC samples to draw. Default is 2000.
- `mcmc_ensemble::AbstractMCMC.AbstractMCMCEnsemble`: The MCMC ensemble to use
    for parallelization. Default is `MCMCSerial()`; that is no parallelization.
- `nruns_pthf::Integer`: The number of runs for the pre-sampler steps.
    Default is 4.
- `maxiters_pthf::Integer`: The maximum number of iterations for the pre-sampler
    steps. Default is 100.
- `nchains::Integer`: The number of MCMC chains to run. Default is 2.

# Returns
An `EpiMethod` object with the specified settings.
"""
function default_inference_method(; max_threads::Integer = 10, ndraws::Integer = 2000,
        mcmc_ensemble::AbstractMCMC.AbstractMCMCEnsemble = MCMCSerial(),
        nruns_pthf::Integer = 4, maxiters_pthf::Integer = 100, nchains::Integer = 2)
    return EpiMethod(
        pre_sampler_steps = [ManyPathfinder(nruns = nruns_pthf, maxiters = maxiters_pthf)],
        sampler = NUTSampler(adtype = AutoForwardDiff(),
            ndraws = ndraws,
            nchains = nchains,
            mcmc_parallel = mcmc_ensemble)
    )
end
