"""
Create inference configurations for the given pipeline. This is the default method.

# Arguments
- `pipeline`: An instance of `AbstractEpiAwarePipeline`.

# Returns
- An object representing the inference configurations.

"""
function make_inference_configs(pipeline::AbstractEpiAwarePipeline)
    default_inference_configs()
end
