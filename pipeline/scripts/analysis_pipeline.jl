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

# Default parameter values
default_gi_param_dict = default_gi_params()
true_Rt = default_Rt()

# truth data configurations
truth_data_configs = make_truth_data_configs(
    gi_means = default_gi_param_dict["gi_means"], gi_stds = default_gi_param_dict["gi_stds"])

truth_data_config_structs = map(truth_data_configs) do d
    TruthSimulationConfig(truth_process = true_Rt, gi_mean = d["gi_mean"], gi_std = d["gi_std"])
end

# Produce the truth data
truth_data = map(truth_data_config_structs) do config
    data, file = produce_or_load(
        simulate_or_infer, config, datadir("truth_data"); prefix = "truth_data")
    plot_truth_data(data, config)
    return data
end
