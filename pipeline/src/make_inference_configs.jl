"""
Create a dictionary of inference configurations.

# Arguments
- `latent_models`: A list of `EpiAware` models for latent processes.
- `gi_means`: A list of means for the generation interval distribution.
- `gi_stds`: A list of standard deviations for the generation interval distribution.
- `igps`: A list of infection growth parameters. Default is `[DirectInfections, ExpGrowthRate, Renewal]`.

# Returns
A dictionary containing the inference configurations.

"""
function make_inference_configs(; latent_models, gi_means, gi_stds,
        igps = [DirectInfections, ExpGrowthRate, Renewal])
    Dict("igp" => igps, "latent_model" => latent_models,
        "gi_mean" => gi_means, "gi_std" => gi_stds) |> dict_list
end
