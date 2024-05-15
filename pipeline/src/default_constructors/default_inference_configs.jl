"""
Constructs and returns the default inference configurations for inference.

# Returns
- `inference_configs`: A dictionary containing the default inference configurations.

"""
function default_inference_configs()
    default_gi_param_dict = default_gi_params()
    default_latent_models_dict = default_epiaware_models()

    inference_configs = make_inference_configs(
        latent_models = collect(values(default_latent_models_dict)),
        gi_means = default_gi_param_dict["gi_means"],
        gi_stds = default_gi_param_dict["gi_stds"])

    return inference_configs
end
