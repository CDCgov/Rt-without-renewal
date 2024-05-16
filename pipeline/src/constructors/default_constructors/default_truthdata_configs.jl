"""
Constructs a dictionary of default truth data configurations using the default_gi_params function.

# Returns
A dictionary containing the default values for `gi_mean` and `gi_std`.

"""
function default_truthdata_configs()
    default_gi_param_dict = default_gi_params()
    Dict("gi_mean" => default_gi_param_dict["gi_means"],
        "gi_std" => default_gi_param_dict["gi_stds"]) |> dict_list
end
