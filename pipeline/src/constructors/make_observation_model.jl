"""
Constructs an observation model for the given pipeline. This is the defualt method.

# Arguments
- `pipeline::AbstractEpiAwarePipeline`: The pipeline for which the observation model is constructed.

# Returns
- `obs`: The constructed observation model.

"""
function make_observation_model(pipeline::AbstractEpiAwarePipeline)
    default_params = make_default_params(pipeline)
    #Model for ascertainment based on day of the week
    dayofweek_logit_ascert = ascertainment_dayofweek(
        NegativeBinomialError(cluster_factor_prior = HalfNormal(default_params["cluster_factor"])),
        latent_model = HierarchicalNormal(std_prior = HalfNormal(0.1)),
        )
    #Default continuous-time model for latent delay in observations
    delay_distribution = make_delay_distribution(pipeline)
    #Model for latent delay in observations
    obs = LatentDelay(dayofweek_logit_ascert, delay_distribution)
    return obs
end
