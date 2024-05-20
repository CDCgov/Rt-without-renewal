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
        tspan, inference_method,
        prfix_name = "observables", datadir_name = "epiaware_observables")
    config = InferenceConfig(
        inference_config["igp"], inference_config["latent_namemodels"].second;
        gi_mean = inference_config["gi_mean"],
        gi_std = inference_config["gi_std"],
        case_data = truthdata["y_t"],
        tspan = tspan,
        epimethod = inference_method
    )

    # produce or load inference results
    prfx = prfix_name * "_igp_" * string(inference_config["igp"]) * "_latentmodel_" *
           inference_config["latent_namemodels"].first * "_truth_gi_mean_" *
           string(truthdata["truth_gi_mean"])

    inference_results, inferencefile = produce_or_load(
        infer, config, datadir(datadir_name); prefix = prfx)
    return inference_results
end

"""
Method for prior predictive modelling.
"""
function generate_inference_results(
        truthdata, inference_config, pipeline::RtwithoutRenewalPriorPipeline;
        tspan, inference_method,
        prfix_name = "prior_observables", datadir_name = "epiaware_observables")
    config = InferenceConfig(
        inference_config["igp"], inference_config["latent_namemodels"].second;
        gi_mean = inference_config["gi_mean"],
        gi_std = inference_config["gi_std"],
        case_data = missing,
        tspan = tspan,
        epimethod = inference_method
    )

    # produce or load inference results
    prfx = prfix_name * "_igp_" * string(inference_config["igp"]) * "_latentmodel_" *
           inference_config["latent_namemodels"].first * "_truth_gi_mean_" *
           string(truthdata["truth_gi_mean"])

    inference_results, inferencefile = produce_or_load(
        infer, config, datadir(datadir_name); prefix = prfx)
    return inference_results
end
