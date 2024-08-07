"""
Create inference configurations for the given pipeline. This is the default method.

# Arguments
- `pipeline`: An instance of `AbstractEpiAwarePipeline`.

# Returns
- An object representing the inference configurations.

"""
function make_inference_configs(pipeline::AbstractEpiAwarePipeline; start = 21)
    gi_param_dict = make_gi_params(pipeline)
    namemodel_vect = make_epiaware_name_latentmodel_pairs(pipeline)
    igps = make_inf_generating_processes(pipeline)
    _igps = filter(igp -> igp != Renewal, igps)
    obs = make_observation_model(pipeline)
    priors = make_model_priors(pipeline)
    default_params = make_default_params(pipeline)
    N = size(make_Rt(pipeline), 1)
    Ts = start:default_params["stride"]:N |> collect

    renewal_configs = Renewal ∉ igps ? Dict[] :
                      Dict("igp" => [Renewal], "latent_namemodels" => namemodel_vect,
        "observation_model" => obs, "gi_mean" => gi_param_dict["gi_means"],
        "gi_std" => gi_param_dict["gi_stds"], "log_I0_prior" => priors["log_I0_prior"],
        "lookahead" => default_params["lookahead"],
        "lookback" => default_params["lookback"], "T" => Ts) |> dict_list

    other_model_configs = Dict("igp" => _igps, "latent_namemodels" => namemodel_vect,
        "observation_model" => obs, "gi_mean" => gi_param_dict["gi_means"][1:1],
        "gi_std" => gi_param_dict["gi_stds"], "log_I0_prior" => priors["log_I0_prior"],
        "lookahead" => default_params["lookahead"],
        "lookback" => default_params["lookback"], "T" => Ts) |> dict_list

    inference_configs = vcat(renewal_configs, other_model_configs)

    selected_inference_configs = _selector(inference_configs, pipeline)
    return selected_inference_configs
end
