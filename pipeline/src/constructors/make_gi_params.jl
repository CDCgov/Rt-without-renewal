"""
Constructs a dictionary of GI (Generation Interval) parameters. This is the
default method.

# Arguments
- `pipeline`: An instance of the `AbstractEpiAwarePipeline` type.

# Returns
A dictionary containing the GI means and GI standard deviations.

"""
function make_gi_params(pipeline::AbstractEpiAwarePipeline)
    gi_means = [2.0, 10.0, 20.0]
    gi_stds = [2.0]
    return Dict("gi_means" => gi_means, "gi_stds" => gi_stds)
end
