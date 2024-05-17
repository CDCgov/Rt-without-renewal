"""
Constructs an inference method for the given pipeline. This is a default method.

# Arguments
- `pipeline`: An instance of `AbstractEpiAwarePipeline`.

# Returns
- An inference method.

"""
function make_inference_method(pipeline::AbstractEpiAwarePipeline; ndraws::Integer = 2000,
        mcmc_ensemble::AbstractMCMC.AbstractMCMCEnsemble = MCMCSerial(),
        nruns_pthf::Integer = 4, maxiters_pthf::Integer = 100, nchains::Integer = 4)
    return EpiMethod(
        pre_sampler_steps = [ManyPathfinder(nruns = nruns_pthf, maxiters = maxiters_pthf)],
        sampler = NUTSampler(adtype = AutoForwardDiff(), ndraws = ndraws,
            nchains = nchains, mcmc_parallel = mcmc_ensemble)
    )
end
