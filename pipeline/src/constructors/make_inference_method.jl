"""
Constructs an inference method for the given pipeline. This is a default method.

# Arguments
- `pipeline`: An instance of `AbstractEpiAwarePipeline`.

# Returns
- An inference method.

"""
function make_inference_method(ndraws::Integer, pipeline::AbstractEpiAwarePipeline;
        mcmc_ensemble::AbstractMCMC.AbstractMCMCEnsemble = MCMCSerial(),
        nruns_pthf::Integer = 4, maxiters_pthf::Integer = 100, nchains::Integer = 4)
    return EpiMethod(
        pre_sampler_steps = [ManyPathfinder(nruns = nruns_pthf, maxiters = maxiters_pthf)],
        sampler = NUTSampler(adtype = AutoReverseDiff(; compile = true), ndraws = ndraws,
            nchains = nchains, mcmc_parallel = mcmc_ensemble)
    )
end

"""
Example pipeline.
"""
function make_inference_method(
        pipeline::EpiAwareExamplePipeline; ndraws::Integer = 20,
        mcmc_ensemble::AbstractMCMC.AbstractMCMCEnsemble = MCMCThreads(),
        nruns_pthf::Integer = 4, maxiters_pthf::Integer = 100, nchains::Integer = 4)
    return EpiMethod(
        pre_sampler_steps = [ManyPathfinder(nruns = nruns_pthf, maxiters = maxiters_pthf)],
        sampler = NUTSampler(
            target_acceptance = 0.9, adtype = AutoReverseDiff(; compile = true),
            ndraws = ndraws, nchains = nchains, mcmc_parallel = mcmc_ensemble)
    )
end

"""
Method for sampling from prior predictive distribution of the model.
"""
function make_inference_method(
        pipeline::AbstractRtwithoutRenewalPipeline, ::Val{:priorpredictive})
    return EpiMethod(
        pre_sampler_steps = AbstractEpiOptMethod[],
        sampler = DirectSample(n_samples = pipeline.ndraws)
    )
end

"""
Constructs an inference method for the Rt-without-renewal pipeline.

# Arguments
- `pipeline`: An instance of the `AbstractRtwithoutRenewalPipeline` type.

# Returns
- An inference method for the pipeline.

# Examples
"""
function make_inference_method(pipeline::AbstractRtwithoutRenewalPipeline)
    if pipeline.priorpredictive
        return make_inference_method(pipeline, Val(:priorpredictive))
    else
        return make_inference_method(
            pipeline.ndraws, pipeline; mcmc_ensemble = pipeline.mcmc_ensemble,
            nruns_pthf = pipeline.nruns_pthf,
            maxiters_pthf = pipeline.maxiters_pthf, nchains = pipeline.nchains)
    end
end
