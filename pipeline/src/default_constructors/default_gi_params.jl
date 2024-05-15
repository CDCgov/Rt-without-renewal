"""
Constructs a dictionary containing default values for the parameters `gi_means` and `gi_stds`.

# Returns
- `Dict`: A dictionary with keys `"gi_means"` and `"gi_stds"`, and corresponding default values.

"""
function default_gi_params()
    gi_means = [2.0, 10.0, 20.0]
    gi_stds = [2.0]
    return Dict("gi_means" => gi_means, "gi_stds" => gi_stds)
end
