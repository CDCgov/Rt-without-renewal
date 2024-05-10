# Analogy: library(targets) in R
using DrWatson

# Activate the project environment
# Analogy: source(functions.R) in targets
@quickactivate "Analysis pipeline"

# Include the AnalysisPipeline module
include(srcdir("AnalysisPipeline.jl"));
# Include some plotting functionality that is useful but not necessary for analysis
# pipeline
include(plotsdir("plot_functions.jl"));

@info("""
      Running the analysis pipeline.
      ---------------------------------------------
      Currently active project is: $(projectname())
      Path of active project: $(projectdir())
      """)

using .AnalysisPipeline

## Other dependencies
# Analogy: tar_option_set(...) in targets
using JLD2, Plots

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

# truth data configurations (e.g. different GI means) and inference configurations
# (e.g. different infection generation processes and latent models etc.)
truth_data_configs = make_truth_data_configs(
    gi_means = default_gi_param_dict["gi_means"], gi_stds = default_gi_param_dict["gi_stds"])

inference_configs = make_inference_configs(
    latent_models = collect(values(latent_models_dict)),
    gi_means = default_gi_param_dict["gi_means"],
    gi_stds = default_gi_param_dict["gi_stds"])

truth_data_config_structs = map(truth_data_configs) do d
    TruthSimulationConfig(
        truth_process = true_Rt, gi_mean = d["gi_mean"], gi_std = d["gi_std"])
end

# Produce and save the truth data
truth_data_scenarios = map(truth_data_config_structs) do truth_data_config_struct
    # generate truth data
    truthdata, truthfile = produce_or_load(
        simulate_or_infer, truth_data_config_struct, datadir("truth_data"); prefix = "truth_data")

    plot_truth_data(truthdata, truth_data_config_struct)

    # Run the inference scenarios
    map(inference_configs[end:end]) do inference_config
        config = InferenceConfig(inference_config["igp"], inference_config["latent_model"];
            gi_mean = inference_config["gi_mean"],
            gi_std = inference_config["gi_std"],
            case_data = truthdata["y_t"],
            tspan = tspan,
            epimethod = inference_method
        )
        # produce or load inference results

        prfx = "observables" * "_igp_" * string(inference_config["igp"]) * "_latentmodel_" *
               latent_models_names[inference_config["latent_model"]] * "_truth_gi_mean_" *
               string(truth_data_config_struct.gi_mean)

        inference_results, inferencefile = produce_or_load(
            simulate_or_infer, config, datadir("epiaware_observables"); prefix = prfx)
        return nothing
    end

    return truthdata
end

# Run the loop over inference jobs
