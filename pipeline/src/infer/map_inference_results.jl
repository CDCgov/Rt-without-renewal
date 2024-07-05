"""
Map the inference results for each inference configuration. This is the default
method for mapping inference results; based on inference results as spawned
tasks from `Dagger.@spawn`.

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
        truthdata, inference_configs, pipeline::AbstractEpiAwarePipeline; inference_method)
    map(inference_configs) do inference_config
        Dagger.@spawn generate_inference_results(
            truthdata, inference_config, pipeline; inference_method)
    end
end
