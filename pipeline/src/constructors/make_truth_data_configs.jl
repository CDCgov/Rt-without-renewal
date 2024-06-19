"""
Create a vector of truth data configurations for `pipeline <: AbstractEpiAwarePipeline`.

# Returns
A vector of dictionaries containing the mean and standard deviation values for
    the generation interval.

"""
function make_truth_data_configs(pipeline::AbstractEpiAwarePipeline)
    gi_param_dict = make_gi_params(pipeline)
    gi_param_dict_list = Dict(
        "gi_mean" => gi_param_dict["gi_means"], "gi_std" => gi_param_dict["gi_stds"]) |>
                         dict_list
    selected_truth_data_configs = _selector(gi_param_dict_list, pipeline)
    return selected_truth_data_configs
end
