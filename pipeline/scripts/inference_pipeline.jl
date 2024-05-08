using DrWatson
@quickactivate "Analysis pipeline"

include(srcdir("AnalysisPipeline.jl"))
include(scriptsdir("common_param_values.jl"))
include(scriptsdir("common_scenarios.jl"))

@info("""
      Running inference on truth data.
      ---------------------------------------------
      Currently active project is: $(projectname())
      Path of active project: $(projectdir())

      """)

## Inference method
# using Distributions, .AnalysisPipeline, EpiAware


num_threads = min(10, Threads.nthreads())
inference_method = EpiMethod(
    pre_sampler_steps = [ManyPathfinder(nruns = 4, maxiters = 100)],
    sampler = NUTSampler(adtype = AutoForwardDiff(),
        ndraws = 2000,
        nchains = num_threads,
        mcmc_parallel = MCMCThreads())
)

##
config = sim_configs[end] |>
    d -> InferenceConfig(d[:igp], d[:latent_model];
        gi_mean = d[:gi_mean],
        gi_std = d[:gi_std],
        case_data = fill(100, 100),
        tspan = (1, 25),
        epimethod = inference_method
    )

##

inference_results

savename(config)
config.igp |> string
