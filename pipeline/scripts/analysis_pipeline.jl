# Analogy: library(targets) in R
using DrWatson

# Activate the project environment
# Analogy: source(functions.R) in targets
quickactivate(@__DIR__(), "Analysis pipeline")
using Dagger

@info("""
      Running the analysis pipeline.
      ---------------------------------------------
      Currently active project is: $(projectname())
      Path of active project: $(projectdir())
      """)

## Other dependencies
# Analogy: tar_option_set(...) in targets
# Add processes for parallel computing and ensure all have same
# dependencies/environment
using Distributed
addprocs(1)

@everywhere begin
    using DrWatson
    quickactivate(@__DIR__(), "Analysis pipeline")
    include(srcdir("AnalysisPipeline.jl"))
end

@everywhere using .AnalysisPipeline

## Run the pipeline steps
# Analogy: list(tar_targets...) followed by tar_make(...) in targets
# This is an intermediate commit that runs but will be updated with a job
# scheduler for these tasks in the next commit. Probably Dagger.jl

# Default parameter values and plot true Rt
# @everywhere begin
#     default_gi_param_dict = default_gi_params()
#     true_Rt = default_Rt()
#     plt_Rt = plot_Rt(true_Rt)
#     latent_models_dict = default_epiaware_models()
#     latent_models_names = Dict(value => key for (key, value) in latent_models_dict)
#     tspan = default_tspan()
#     inference_method = default_inference_method()
# end

default_gi_param_dict_thunk = Dagger.@spawn default_gi_params()
true_Rt_thunk = Dagger.@spawn default_Rt()
plt_Rt_thunk = Dagger.@spawn plot_Rt(true_Rt_thunk)
latent_models_dict_thunk = Dagger.@spawn default_epiaware_models()
latent_models_names_thunk = Dagger.@spawn default_latent_models_names()
tspan_thunk = Dagger.@spawn default_tspan()
inference_method_thunk = Dagger.@spawn default_inference_method()

# fetch the default GI parameters and latent models from their `EagerThunk`s
default_gi_param_dict = fetch(default_gi_param_dict_thunk)
latent_models_dict = fetch(latent_models_dict_thunk)

# truth data configurations (e.g. different GI means)

truth_data_configs = make_truth_data_configs(
    gi_means = default_gi_param_dict["gi_means"], gi_stds = default_gi_param_dict["gi_stds"])

# inference configurations
# (e.g. different infection generation processes and latent models etc.)
inference_configs = make_inference_configs(
    latent_models = collect(values(latent_models_dict)),
    gi_means = default_gi_param_dict["gi_means"],
    gi_stds = default_gi_param_dict["gi_stds"])

# Produce and save the truth data
truthdata_from_configs = @sync map(truth_data_configs) do truth_data_config
    # generate truth data
    truth_thunk = Dagger.@spawn generate_truthdata_from_config(
        truth_data_config; plot = true)
    # # Run the inference scenarios
    for inference_config in inference_configs
        inference_thunks = Dagger.@spawn generate_inference_results(
            truth_thunk, inference_config; tspan_thunk, inference_method_thunk,
            truth_data_config, latent_models_names_thunk)
    end
    truthdata = fetch(truth_thunk)
    return truthdata
end
