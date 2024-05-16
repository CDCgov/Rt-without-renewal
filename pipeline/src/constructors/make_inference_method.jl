"""
Constructs an inference method for the given pipeline.

# Arguments
- `pipeline`: An instance of `AbstractEpiAwarePipeline`.

# Returns
- An inference method.

"""
function make_inference_method(pipeline::AbstractEpiAwarePipeline)
    default_inference_method()
end
