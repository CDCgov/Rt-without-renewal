# Analogy: library(targets) in R
using DrWatson

# Activate the project environment
# Analogy: source(functions.R) in targets
@quickactivate "Analysis pipeline"

# Include the AnalysisPipeline module
include(srcdir("AnalysisPipeline.jl"));

@info("""
      Running the analysis pipeline.
      ---------------------------------------------
      Currently active project is: $(projectname())
      Path of active project: $(projectdir())
      """)

## Other dependencies
# Analogy: tar_option_set(...) in targets
using .AnalysisPipeline

## Run the pipeline steps
# Analogy: list(tar_targets...) followed by tar_make(...) in targets
# This is an intermediate commit that runs but will be updated with a job
# scheduler for these tasks in the next commit. Probably Dagger.jl

# Default parameter values and plot true Rt
default_gi_param_dict = default_gi_params()
true_Rt = default_Rt()
plt_Rt = plot_Rt(true_Rt)
latent_models_dict = default_epiaware_models()
latent_models_names = Dict(value => key for (key, value) in latent_models_dict)
tspan = default_tspan()
inference_method = default_inference_method()

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
truth_data_scenarios = map(truth_data_configs[1:1]) do truth_data_config
    @info "Running truth data scenario with GI mean: $(truth_data_config["gi_mean"])"
    # generate truth data
    truthdata, truthfile = generate_truthdata_from_config(
        truth_data_config; plot = true)

    # Run the inference scenarios
    map(inference_configs[1:1]) do inference_config
        @info "Running inference scenario with IGP: $(inference_config["igp"]), latent model: " *
              latent_models_names[inference_config["latent_model"]]
        inference_results, inferencefile = generate_inference_results(
            truthdata, inference_config; tspan, inference_method,
            truth_data_config, latent_models_names)
        return nothing
    end

    return truthdata
end
