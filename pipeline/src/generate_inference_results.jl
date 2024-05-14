"""
Generate inference results based on the given configuration of inference model options.

# Arguments
- `inference_config`: A dictionary containing the inference configuration choices.
- `tspan`: The time span for the inference.
- `inference_method`: The method used for inference.
- `truth_data_config`: A dictionary containing the truth data configuration parameters. This is only
    used to generate the file name for the inference results.

# Returns
- `inference_results`: The generated inference results.
- `inferencefile`: The file path where the inference results are stored.
"""
function generate_inference_results(truthdata, inference_config; tspan, inference_method,
        truth_data_config, latent_models_names,
        prfix_name = "observables", datadir_name = "epiaware_observables")
    config = InferenceConfig(inference_config["igp"], inference_config["latent_model"];
        gi_mean = inference_config["gi_mean"],
        gi_std = inference_config["gi_std"],
        case_data = truthdata["y_t"],
        tspan = tspan,
        epimethod = inference_method
    )
    # produce or load inference results

    prfx = prfix_name * "_igp_" * string(inference_config["igp"]) * "_latentmodel_" *
           latent_models_names[inference_config["latent_model"]] * "_truth_gi_mean_" *
           string(truth_data_config["gi_mean"])

    inference_results, inferencefile = produce_or_load(
        infer, config, datadir(datadir_name); prefix = prfx)
    return inference_results, inferencefile
end
