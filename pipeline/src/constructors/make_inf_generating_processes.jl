"""
Constructs and returns a vector of infection-generating process types for the given
pipeline. This is the default method.

# Arguments
- `pipeline`: An instance of `AbstractEpiAwarePipeline`.

# Returns
An array of infection-generating process types.

"""
function make_inf_generating_processes(pipeline::AbstractEpiAwarePipeline)
    return [DirectInfections, ExpGrowthRate, Renewal]
end
