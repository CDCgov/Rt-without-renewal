using DrWatson
@quickactivate "Analysis pipeline"

include(srcdir("AnalysisPipeline.jl"))
include(scriptsdir("common_param_values.jl"));

@info("""
      Setting up list of inference scenarios.
      ---------------------------------------------
      Currently active project is: $(projectname())
      Path of active project: $(projectdir())

      """)

## Set up the truth Rt and save a plot of it
# Set up the EpiAware models to use for inference.
using .AnalysisPipeline, Plots, EpiAware, Distributions, ADTypes, AbstractMCMC

#Common priors for initial process and std priors
transformed_process_init_prior = Normal(0.0, 0.25)
underlying_std_prior = HalfNormal(0.25)

ar = AR(damp_priors = [Beta(0.5, 0.5)], std_prior = underlying_std_prior,
    init_priors = [transformed_process_init_prior])

rw = RandomWalk(
    std_prior = underlying_std_prior, init_prior = transformed_process_init_prior)

diff_ar = DiffLatentModel(; model = ar, init_priors = [transformed_process_init_prior])

wkly_ar, wkly_rw, wkly_diff_ar = [ar, rw, diff_ar] .|>
                                 model -> BroadcastLatentModel(model, 7, RepeatBlock())

naming_scheme = Dict(
    wkly_ar => "wkly_ar", wkly_rw => "wkly_rw", wkly_diff_ar => "wkly_diff_ar")

## Parameter settings
# Rolled out to a vector of inference configurations using `dict_list`.

sim_configs = Dict(:igp => [DirectInfections, ExpGrowthRate, Renewal],
    :latent_model => [wkly_ar, wkly_rw, wkly_diff_ar],
    :gi_mean => gi_means, :gi_std => gi_stds) |> dict_list

#Common thread count
num_threads = min(10, Threads.nthreads());

#Common inference method
inference_method = EpiMethod(
    pre_sampler_steps = [ManyPathfinder(nruns = 4, maxiters = 100)],
    sampler = NUTSampler(adtype = AutoForwardDiff(),
        ndraws = 2000,
        nchains = num_threads,
        mcmc_parallel = MCMCThreads())
)
