using DrWatson
@quickactivate "Analysis pipeline"

# Include the AnalysisPipeline module
include(srcdir("AnalysisPipeline.jl"))
# Include the common parameter values
include(scriptsdir("common_param_values.jl"))
# Include the common inference scenarios
include(scriptsdir("common_scenarios.jl"))

@info("""
      Running inference on truth data.
      ---------------------------------------------
      Currently active project is: $(projectname())
      Path of active project: $(projectdir())

      """)

## Inference methods
using Distributions, .AnalysisPipeline, EpiAware, JLD2, ADTypes, AbstractMCMC

for filename in readdir(datadir("truth_data"))
    # Load the truth data
    D = JLD2.load(joinpath(datadir("truth_data"), filename))

    # Extract the gi_mean value from the filename
    _, truth_data_vals = parse_savename(filename)
    truth_data_gi_mean = truth_data_vals["gi_mean"]

    # Set up and run the inference scenarios
    for d in sim_configs
        config = InferenceConfig(d[:igp], d[:latent_model];
            gi_mean = d[:gi_mean],
            gi_std = d[:gi_std],
            case_data = D["y_t"],
            tspan = inference_tspan,
            epimethod = inference_method
        )
        prfx = "observables" * "_igp_" * string(d[:igp]) * "_latentmodel_" *
               naming_scheme[d[:latent_model]] * "_truth_gi_mean_" *
               string(truth_data_gi_mean)

        data, file = produce_or_load(
            simulate_or_infer, config, datadir("epiaware_observables"); prefix = prfx)
    end
end
