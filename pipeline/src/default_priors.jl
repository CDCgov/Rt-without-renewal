"""
Constructs a dictionary of default prior distributions for the parameters used
    in `EpiAware` models.

# Returns
- `Dict{String, Distribution}`: A dictionary containing the default prior
    distributions.

"""
function default_priors()
    transformed_process_init_prior = Normal(0.0, 0.25)
    std_prior = HalfNormal(0.25)
    damp_param_prior = Beta(0.5, 0.5)

    return Dict(
        "transformed_process_init_prior" => transformed_process_init_prior,
        "std_prior" => std_prior,
        "damp_param_prior" => damp_param_prior
    )
end
