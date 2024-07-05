"""
Generate inference results using the specified truth data and pipeline.

# Arguments
- `truthdata`: The truth data used for generating inference results.
- `pipeline`: An instance of the `AbstractAbstractEpiAwarePipeline` sub-type.

# Returns
An array of inference results.

"""
function do_inference(truthdata, pipeline::AbstractEpiAwarePipeline)
    inference_configs = make_inference_configs(pipeline)
    inference_method = make_inference_method(pipeline)
    inference_results = map_inference_results(
        truthdata, inference_configs, pipeline; inference_method)
    return inference_results
end
