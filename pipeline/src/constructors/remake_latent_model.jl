"""
Constructs and returns a latent model based on the provided `inference_config` and `pipeline`.
The purpose of this function is to make adjustments to the latent model based on the
full `inference_config` provided.

The `tscale` argument is used to scale the standard deviation of the latent model based on the
idea that some processes have a variance that is (approximately) proportional to a time period (due to non-stationarity)
and some processes have a variance that is constant in time (at stationarity). The default
value is `sqrt(21.0)`, which corresponds to matching the variance of stationary processes to
the eventual variance of non-stationary process after 21 days.

The `pipeline` argument is used for dispatch purposes.

# Returns
- A latent model object which can be one of `DiffLatentModel`, `AR`, or `RandomWalk` depending on the `latent_model_name` and `igp` specified in `inference_config`.

# Details
- The function first constructs a dictionary of priors using `make_model_priors(pipeline)`.
- It then retrieves the `igp` (inference generation process) and `latent_model_name` from `inference_config`.
- Depending on the `latent_model_name` and `igp`, it constructs and returns the appropriate latent model:
  - `"diff_ar"`: Constructs a `DiffLatentModel` with an `AR` model.
  - `"ar"`: Constructs an `AR` model.
  - `"rw"`: Constructs a `RandomWalk` model.
- The priors for the models are set based on the `prior_dict` and the `tscale` parameter.

"""
function remake_latent_model(inference_config::Dict,
        pipeline::AbstractRtwithoutRenewalPipeline; tscale = sqrt(21.0))
    #Baseline choices
    prior_dict = make_model_priors(pipeline)
    igp = inference_config["igp"]
    latent_model_name = inference_config["latent_namemodels"].first

    if latent_model_name == "diff_ar"
        if igp == Renewal
            ar = AR(damp_priors = [prior_dict["damp_param_prior"]],
                std_prior = HalfNormal(0.05 / tscale),
                init_priors = [prior_dict["transformed_process_init_prior"]])
            diff_ar = DiffLatentModel(;
                model = ar, init_priors = [prior_dict["transformed_process_init_prior"]])
            return diff_ar
        elseif igp == ExpGrowthRate
            ar = AR(damp_priors = [prior_dict["damp_param_prior"]],
                std_prior = HalfNormal(0.005 / tscale),
                init_priors = [prior_dict["transformed_process_init_prior"]])
            diff_ar = DiffLatentModel(;
                model = ar, init_priors = [prior_dict["transformed_process_init_prior"]])
            return diff_ar
        elseif igp == DirectInfections
            ar = AR(damp_priors = [Beta(9, 1)],
                std_prior = HalfNormal(0.05 / tscale),
                init_priors = [prior_dict["transformed_process_init_prior"]])
            diff_ar = DiffLatentModel(;
                model = ar, init_priors = [prior_dict["transformed_process_init_prior"]])
            return diff_ar
        end
    elseif latent_model_name == "ar"
        if igp == Renewal
            ar = AR(damp_priors = [Beta(2, 8)],
                std_prior = HalfNormal(0.25),
                init_priors = [prior_dict["transformed_process_init_prior"]])
            return ar
        elseif igp == ExpGrowthRate
            ar = AR(damp_priors = [prior_dict["damp_param_prior"]],
                std_prior = HalfNormal(0.025),
                init_priors = [prior_dict["transformed_process_init_prior"]])
            return ar
        elseif igp == DirectInfections
            ar = AR(damp_priors = [Beta(9, 1)],
                std_prior = HalfNormal(0.25),
                init_priors = [prior_dict["transformed_process_init_prior"]])
            return ar
        end
    elseif latent_model_name == "rw"
        if igp == Renewal
            rw = RandomWalk(
                std_prior = HalfNormal(0.05 / tscale),
                init_prior = prior_dict["transformed_process_init_prior"])
            return rw
        elseif igp == ExpGrowthRate
            rw = RandomWalk(
                std_prior = HalfNormal(0.005 / tscale),
                init_prior = prior_dict["transformed_process_init_prior"])
            return rw
        elseif igp == DirectInfections
            rw = RandomWalk(
                std_prior = HalfNormal(0.1 / tscale),
                init_prior = prior_dict["transformed_process_init_prior"])
            return rw
        end
    end
end

"""
Pass through fallback dispatch.
"""
function remake_latent_model(inference_config::Dict, pipeline::AbstractEpiAwarePipeline)
    inference_config["latent_namemodels"].second
end
