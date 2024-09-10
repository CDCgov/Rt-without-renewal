"""
This is an internal method that generates part of the prefix for the inference
    results file name from the truth data and inference configuration.
"""
function _prefix_from_config(truthdata, inference_config)
    igp_str = string(inference_config["igp"]) |> str -> split(str, ".")[end]

    return "_igp_" * igp_str * "_latentmodel_" *
           inference_config["latent_namemodels"].first * "_truth_gi_mean_" *
           string(truthdata["truth_gi_mean"]) * "_inference_T_" *
           string(inference_config["T"])
end

"""
This is an internal method that generates the part of the prefix for the inference
    results file name from the pipeline.
"""
_prefix_from_pipeline(pipeline::AbstractEpiAwarePipeline) = "observables"
function _prefix_from_pipeline(pipeline::AbstractRtwithoutRenewalPipeline)
    "inference_" * pipeline.prefix
end

"""
This is an internal method that generates the prefix for the inference results file name.
"""
function _inference_prefix(truthdata, inference_config, pipeline::AbstractEpiAwarePipeline)
    return "observables" * "_igp_" * string(inference_config["igp"]) * "_latentmodel_" *
           inference_config["latent_namemodels"].first * "_truth_gi_mean_" *
           string(truthdata["truth_gi_mean"]) * "_used_gi_mean_" *
           string(inference_config["gi_mean"])
end

function _inference_prefix(truthdata, inference_config, pipeline::EpiAwareExamplePipeline)
    return "testmode_observables" * "_igp_" * string(inference_config["igp"]) *
           "_latentmodel_" *
           inference_config["latent_namemodels"].first * "_truth_gi_mean_" *
           string(truthdata["truth_gi_mean"]) * "_used_gi_mean_" *
           string(inference_config["gi_mean"])
end

function _inference_prefix(
        truthdata, inference_config, pipeline::RtwithoutRenewalPriorPipeline)
    return "prior_observables" * "_igp_" * string(inference_config["igp"]) *
           "_latentmodel_" *
           inference_config["latent_namemodels"].first * "_truth_gi_mean_" *
           string(inference_config["gi_mean"])
end

"""
This is an internal method that generates the prefix for the inference results file name for
    `pipeline` objects of type `AbstractRtwithoutRenewalPipeline`.
"""
function _inference_prefix(
        truthdata, inference_config, pipeline::AbstractRtwithoutRenewalPipeline)
    return _prefix_from_pipeline(pipeline) *
           _prefix_from_config(truthdata, inference_config)
end

"""
Internal method for setting the data directory path for the inference data.
"""
_get_inferencedatadir_str(pipeline::AbstractEpiAwarePipeline) = "epiaware_observables"
function _get_truthdatadir_str(pipeline::AbstractRtwithoutRenewalPipeline)
    pipeline.testmode ? mktempdir() : "epiaware_observables"
end
