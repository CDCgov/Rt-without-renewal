"""
Generate inference results based on the given configuration of inference model options.

# Arguments
- `truthdata`: The truth data used for generating inference results.
- `inference_config`: A dictionary containing the inference configuration choices.
- `pipeline::AbstractEpiAwarePipeline`: The pipeline object which sets pipeline
    behavior. This is the default method.
- `tspan`: The time span for the inference.
- `inference_method`: The method used for inference.


# Returns
- `inference_results`: The generated inference results.
"""
function generate_inference_results(
        truthdata, inference_config, pipeline::AbstractEpiAwarePipeline;
        tspan, inference_method, datadir_name = "epiaware_observables")
    config = InferenceConfig(
        inference_config; case_data = truthdata["y_t"], tspan, epimethod = inference_method)

    # produce or load inference results
    prfx = _inference_prefix(truthdata, inference_config, pipeline)

    inference_results, inferencefile = produce_or_load(
        infer, config, datadir(datadir_name); prefix = prfx)
    return inference_results
end

"""
Generate inference results for examples/test mode, saving results in a temporary directory
which is deleted after the function call.

# Arguments
- `truthdata`: The truth data used for generating inference results.
- `inference_config`: A dictionary containing the inference configuration choices.
- `pipeline::EpiAwareExamplePipeline`: The pipeline object which sets pipeline
    behavior. This is the example method.
- `tspan`: The time span for the inference.
- `inference_method`: The method used for inference.
- `prfix_name`: A string specifying the prefix for the inference results file name.
    Default is `"observables"`.


# Returns
- `inference_results`: The generated inference results.
"""
function generate_inference_results(
        truthdata, inference_config, pipeline::EpiAwareExamplePipeline;
        tspan, inference_method)
    config = InferenceConfig(inference_config; case_data = truthdata["y_t"],
        tspan = tspan, epimethod = inference_method)

    # produce or load inference results
    prfx = _inference_prefix(truthdata, inference_config, pipeline)

    datadir_name = mktempdir()

    inference_results, inferencefile = produce_or_load(
        infer, config, datadir_name; prefix = prfx)
    return inference_results
end

"""
Method for prior predictive modelling.
"""
function generate_inference_results(
        inference_config, pipeline::RtwithoutRenewalPriorPipeline;
        tspan)
    config = InferenceConfig(
        inference_config; case_data = missing, tspan, epimethod = DirectSample())

    # produce or load inference results
    prfx = _inference_prefix(truthdata, inference_config, pipeline)

    datadir_name = mktempdir()

    inference_results, inferencefile = produce_or_load(
        infer, config, datadir(datadir_name); prefix = prfx)
    return inference_results
end
