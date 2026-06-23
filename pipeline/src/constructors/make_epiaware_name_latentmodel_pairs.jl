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

    # EpiAware 0.2: the innovation std moved from a `std_prior` kwarg into the
    # `ϵ_t` error-term model. `HierarchicalNormal(std_prior = σ)` reproduces the
    # old behaviour (zₜ ~ Normal(0, σ), σ ~ std_prior).
    ar = AR(damp_priors = [prior_dict["damp_param_prior"]],
        init_priors = [prior_dict["transformed_process_init_prior"]],
        ϵ_t = HierarchicalNormal(std_prior = prior_dict["std_prior"]))

    rw = RandomWalk(
        init_prior = prior_dict["transformed_process_init_prior"],
        ϵ_t = HierarchicalNormal(std_prior = prior_dict["std_prior"]))

    diff_ar = DiffLatentModel(;
        model = ar, init_priors = [prior_dict["transformed_process_init_prior"]])

    return ["ar" => ar, "rw" => rw, "diff_ar" => diff_ar]
end
