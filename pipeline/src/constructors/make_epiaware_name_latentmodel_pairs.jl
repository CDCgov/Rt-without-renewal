"""
Constructs a dictionary of name-model pairs for the EpiAware pipeline. This is
the default method.

# Arguments
- `pipeline::AbstractEpiaAwarePipeline`: The EpiAware pipeline object.

# Returns
A dictionary containing the name-model pairs.

"""
function make_epiaware_name_latentmodel_pairs(pipeline::AbstractEpiAwarePipeline)
    prior_dict = make_model_priors(pipeline)

    ar = AR(damp_priors = [prior_dict["damp_param_prior"]],
        std_prior = prior_dict["std_prior"],
        init_priors = [prior_dict["transformed_process_init_prior"]])

    rw = RandomWalk(
        std_prior = prior_dict["std_prior"], init_prior = prior_dict["transformed_process_init_prior"])

    diff_ar = DiffLatentModel(;
        model = ar, init_priors = [prior_dict["transformed_process_init_prior"]])

    wkly_ar, wkly_rw, wkly_diff_ar = [ar, rw, diff_ar] .|>
                                     model -> BroadcastLatentModel(model, 7, RepeatBlock())

    return ["wkly_ar" => wkly_ar, "wkly_rw" => wkly_rw, "wkly_diff_ar" => wkly_diff_ar]
end
