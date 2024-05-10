"""
Constructs and returns a dictionary of default epiaware models.

The function creates three models for epiaware analysis:
    autoregressive (AR), random walk (RW), and difference autoregressive
    (DiffLatentModel) models. These models are used for analyzing time series
    data in epidemiology.

Returns
-------
models_dict::Dict{String, LatentModel}
    A dictionary containing the default epiaware models, with the following keys:
    - "wkly_ar": Weekly autoregressive model
    - "wkly_rw": Weekly random walk model
    - "wkly_diff_ar": Weekly differenced autoregressive model
"""
function default_epiaware_models()
    prior_dict = default_priors()

    ar = AR(damp_priors = [prior_dict["damp_param_prior"]],
        std_prior = prior_dict["std_prior"],
        init_priors = [prior_dict["transformed_process_init_prior"]])

    rw = RandomWalk(
        std_prior = prior_dict["std_prior"], init_prior = prior_dict["transformed_process_init_prior"])

    diff_ar = DiffLatentModel(;
        model = ar, init_priors = [prior_dict["transformed_process_init_prior"]])

    wkly_ar, wkly_rw, wkly_diff_ar = [ar, rw, diff_ar] .|>
                                     model -> BroadcastLatentModel(model, 7, RepeatBlock())

    return Dict("wkly_ar" => wkly_ar, "wkly_rw" => wkly_rw, "wkly_diff_ar" => wkly_diff_ar)
end
