"""
Constructs a dictionary of default parameters for the given `pipeline`. This is the default method.
These are parameters that aren't expected to change by experiment.

# Arguments
- `pipeline`: An instance of `AbstractEpiAwarePipeline`.

# Returns
A dictionary containing the default parameters:
- `"Rt"`: The value returned by `make_Rt(pipeline)`.
- `"logit_daily_ascertainment"`: An array of values, with the first 5 elements set to 0 and the last 2 elements set to -0.5.
- `"cluster_factor"`: The value 0.1.
- `"I0"`: The value 100.0.
- `"α_delay"`: Shape parameter of Gamma distributed delay in observation. The value 4.0.
- `"θ_delay"`: Shape parameter of Gamma distributed delay in observation. The value 5.0 / 4.0.
"""
function make_default_params(pipeline::AbstractEpiAwarePipeline)
    Rt = make_Rt(pipeline)
    logit_daily_ascertainment = [zeros(5); -0.5 * ones(2)]
    cluster_factor = 0.05
    I0 = 100.0
    α_delay = 4.0
    θ_delay = 5.0 / 4.0
    lookahead = 21
    return Dict(
        "Rt" => Rt,
        "logit_daily_ascertainment" => logit_daily_ascertainment,
        "cluster_factor" => cluster_factor,
        "I0" => I0,
        "α_delay" => α_delay,
        "θ_delay" => θ_delay,
        "lookahead" => lookahead)
end
