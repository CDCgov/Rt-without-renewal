"""
Create inference configurations for the given pipeline. This is the default method.

# Arguments
- `pipeline`: An instance of `AbstractEpiAwarePipeline`.

# Returns
- An object representing the inference configurations.

"""
function make_inference_configs(pipeline::AbstractEpiAwarePipeline)
    gi_param_dict = make_gi_params(pipeline)
    namemodel_vect = make_epiaware_name_latentmodel_pairs(pipeline)
    igps = make_inf_generating_processes(pipeline)
    obs = make_observation_model(pipeline)
    priors = make_model_priors(pipeline)
    default_params = make_default_params(pipeline)

    inference_configs = Dict("igp" => igps, "latent_namemodels" => namemodel_vect,
        "observation_model" => obs, "gi_mean" => gi_param_dict["gi_means"],
        "gi_std" => gi_param_dict["gi_stds"], "log_I0_prior" => priors["log_I0_prior"],
        "lookahead" => default_params["lookahead"]) |>
                        dict_list

    selected_inference_configs = _selector(inference_configs, pipeline)
    return selected_inference_configs
end
