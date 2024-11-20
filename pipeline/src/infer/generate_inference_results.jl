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
        truthdata, inference_config, pipeline::AbstractEpiAwarePipeline)
    tspan = make_tspan(
        pipeline; T = inference_config["T"], lookback = inference_config["lookback"])
    inference_method = make_inference_method(pipeline)
    config = InferenceConfig(
        inference_config; case_data = truthdata["y_t"], truth_I_t = truthdata["I_t"],
        truth_I0 = truthdata["truth_I0"], tspan, epimethod = inference_method, pipeline = pipeline)

    # produce or load inference results
    prfx = _inference_prefix(truthdata, inference_config, pipeline)
    _datadir_str = _get_inferencedatadir_str(pipeline)

    inference_results,
    inferencefile = produce_or_load(
        infer, config, _datadir_str; prefix = prfx)
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
        truthdata, inference_config, pipeline::EpiAwareExamplePipeline)
    tspan = make_tspan(
        pipeline; T = inference_config["T"], lookback = inference_config["lookback"])
    inference_method = make_inference_method(pipeline)
    config = InferenceConfig(
        inference_config; case_data = truthdata["y_t"], truth_I_t = truthdata["I_t"],
        truth_I0 = truthdata["truth_I0"], tspan = tspan, epimethod = inference_method, pipeline = pipeline)

    # produce or load inference results
    prfx = _inference_prefix(truthdata, inference_config, pipeline)

    datadir_name = mktempdir()

    inference_results,
    inferencefile = produce_or_load(
        infer, config, datadir_name; prefix = prfx)
    return inference_results
end
