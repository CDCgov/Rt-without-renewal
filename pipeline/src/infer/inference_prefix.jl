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

function _inference_prefix(truthdata, inference_config, pipeline::SmoothOutbreakPipeline)
    return "smooth_outbreak" * "_igp_" * string(inference_config["igp"]) * "_latentmodel_" *
           inference_config["latent_namemodels"].first * "_truth_gi_mean_" *
           string(truthdata["truth_gi_mean"]) * "_used_gi_mean_" *
           string(inference_config["gi_mean"])
end

function _inference_prefix(truthdata, inference_config, pipeline::MeasuresOutbreakPipeline)
    return "measures_outbreak" * "_igp_" * string(inference_config["igp"]) *
           "_latentmodel_" *
           inference_config["latent_namemodels"].first * "_truth_gi_mean_" *
           string(truthdata["truth_gi_mean"]) * "_used_gi_mean_" *
           string(inference_config["gi_mean"])
end

function _inference_prefix(truthdata, inference_config, pipeline::SmoothEndemicPipeline)
    return "smooth_endemic" * "_igp_" * string(inference_config["igp"]) * "_latentmodel_" *
           inference_config["latent_namemodels"].first * "_truth_gi_mean_" *
           string(truthdata["truth_gi_mean"]) * "_used_gi_mean_" *
           string(inference_config["gi_mean"])
end

function _inference_prefix(truthdata, inference_config, pipeline::RoughEndemicPipeline)
    return "rough_endemic" * "_igp_" * string(inference_config["igp"]) * "_latentmodel_" *
           inference_config["latent_namemodels"].first * "_truth_gi_mean_" *
           string(truthdata["truth_gi_mean"]) * "_used_gi_mean_" *
           string(inference_config["gi_mean"])
end
