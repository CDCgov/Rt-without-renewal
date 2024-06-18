"""
Create a vector of truth data configurations for `pipeline <: AbstractEpiAwarePipeline`.
    This is the default method.

# Returns
A vector of dictionaries containing the mean and standard deviation values for
    the generation interval.

"""
function make_truth_data_configs(pipeline::AbstractEpiAwarePipeline)
    gi_param_dict = make_gi_params(pipeline)
    return Dict(
        "gi_mean" => gi_param_dict["gi_means"], "gi_std" => gi_param_dict["gi_stds"]) |>
           dict_list
end

"""
Create a vector of truth data configurations for `pipeline <: AbstractEpiAwarePipeline`.
This is the example method, which only returns a randomly selected truth data configuration.
"""
function make_truth_data_configs(pipeline::EpiAwareExamplePipeline)
    gi_param_dict = make_gi_params(pipeline)
    return Dict(
               "gi_mean" => gi_param_dict["gi_means"], "gi_std" => gi_param_dict["gi_stds"]) |>
           dict_list |> list -> [rand(list)]
end
