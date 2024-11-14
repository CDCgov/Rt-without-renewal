"""
Constructs and returns a dictionary of prior distributions for the latent model
parameters. This is the default method.

# Arguments
- `pipeline`: An instance of the `AbstractEpiAwarePipeline` type.

# Returns
A dictionary containing the following prior distributions:
- `"transformed_process_init_prior"`: A normal distribution with mean 0.0 and
standard deviation 0.25.
- `"std_prior"`: A half-normal distribution with standard deviation 0.25.
- `"damp_param_prior"`: A beta distribution with shape parameters 0.5 and 0.5.

"""
function make_model_priors(pipeline::AbstractEpiAwarePipeline)
    transformed_process_init_prior = Normal(0.0, 0.25)
    std_prior = HalfNormal(0.25)
    damp_param_prior = Beta(0.5, 0.5)
    log_I0_prior = Normal(log(100.0), 1e-5)

    return Dict(
        "transformed_process_init_prior" => transformed_process_init_prior,
        "std_prior" => std_prior,
        "damp_param_prior" => damp_param_prior,
        "log_I0_prior" => log_I0_prior
    )
end

function make_model_priors(igp, latent_model, pipeline::AbstractEpiAwarePipeline)
    @assert igp in [Renewal, ExpGrowthRate, DirectInfections] "`igp` must be a valid model type"

    transformed_process_init_prior = Normal(0.0, 0.25)
    std_prior = HalfNormal(0.25)
    damp_param_prior = Beta(0.5, 0.5)
    log_I0_prior = Normal(log(100.0), 1e-5)

    return Dict(
        "transformed_process_init_prior" => transformed_process_init_prior,
        "std_prior" => std_prior,
        "damp_param_prior" => damp_param_prior,
        "log_I0_prior" => log_I0_prior
    )
end

# function set_init_and_std_prior(epimodel)
#     if epimodel isa Renewal
#         init_prior = Normal(log(1.2), 0.25)
#         std_prior = HalfNormal(0.05)
#         return (; init_prior, std_prior)
#     elseif epimodel isa ExpGrowthRate
#         init_prior = Normal(0.1, 0.025)
#         std_prior = LogNormal(log(0.025), 0.01)
#         return (; init_prior, std_prior)
#     elseif epimodel isa DirectInfections
#         init_prior = Normal(log(100.0), 0.25)
#         std_prior = HalfNormal(0.025)
#         return (; init_prior, std_prior)
#     end
# end
