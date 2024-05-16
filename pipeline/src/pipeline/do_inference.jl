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
    tspan = make_tspan(pipeline)
    inference_method = make_inference_method(pipeline)
    latent_models_names = make_latent_models_names(pipeline)

    inference_results = map(inference_configs) do inference_config
        Dagger.@spawn generate_inference_results(
            truthdata, inference_config, pipeline; tspan,
            inference_method, latent_models_names)
    end
    return inference_results
end
