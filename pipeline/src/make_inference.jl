"""
Generate inference results using the specified truth data and pipeline.

# Arguments
- `truthdata`: The truth data used for generating inference results.
- `pipeline`: An instance of the `EpiAwarePipeline` type.

# Returns
An array of inference results.

"""
function make_inference(truthdata, pipeline::EpiAwarePipeline)
    inference_configs = default_inference_configs()
    tspan = default_tspan()
    inference_method = default_inference_method()
    latent_models_names = default_latent_models_names()

    inference_results = map(inference_configs) do inference_config
        Dagger.@spawn generate_inference_results(
            truthdata, inference_config; tspan, inference_method, latent_models_names)
    end
    return inference_results
end
