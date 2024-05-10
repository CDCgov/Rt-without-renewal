"""
Create a dictionary of truth data configurations.

# Arguments
- `gi_means`: The mean values for gi.
- `gi_stds`: The standard deviations for gi.

# Returns
A dictionary containing the mean and standard deviation values for gi.

"""
function make_truth_data_configs(; gi_means, gi_stds)
    Dict("gi_mean" => gi_means, "gi_std" => gi_stds) |> dict_list
end
