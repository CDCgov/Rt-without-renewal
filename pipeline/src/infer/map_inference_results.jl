"""
Map the inference results for each inference configuration. This is the default
method for mapping inference results.

# Arguments
- `truthdata`: The truth data used for generating inference results.
- `inference_configs`: A collection of inference configurations.
- `pipeline`: The pipeline object.
- `tspan`: The time span for the inference.
- `inference_method`: The method used for inference.

# Returns
- A vector of generated inference results.

"""
function map_inference_results(
        truthdata, inference_configs, pipeline::AbstractEpiAwarePipeline)
    pmap(inference_configs) do inference_config
        generate_inference_results(truthdata, inference_config, pipeline)
    end
end
