"""
Constructs and returns the default inference configurations for inference.

# Returns
- `inference_configs`: A dictionary containing the default inference configurations.

"""
function default_inference_configs()
    default_gi_param_dict = default_gi_params()
    default_latent_models_dict = default_epiaware_models()
    igps = [DirectInfections, ExpGrowthRate, Renewal]

    inference_configs = Dict(
        "igp" => igps, "latent_model" => collect(values(default_latent_models_dict)),
        "gi_mean" => default_gi_param_dict["gi_means"],
        "gi_std" => default_gi_param_dict["gi_stds"]) |> dict_list

    return inference_configs
end
