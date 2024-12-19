"""
Constructs an observation model for the given pipeline. This is the default method.

# Arguments
- `pipeline::AbstractEpiAwarePipeline`: The pipeline for which the observation model is constructed.

# Returns
- `obs`: The constructed observation model.

"""
function make_observation_model(pipeline::AbstractEpiAwarePipeline)
    default_params = make_default_params(pipeline)
    #Model for ascertainment based on day of the week
    dayofweek_logit_ascert = ascertainment_dayofweek(NegativeBinomialError(cluster_factor_prior = HalfNormal(default_params["cluster_factor"])))
    #Default continuous-time model for latent delay in observations
    delay_distribution = make_delay_distribution(pipeline)
    #Model for latent delay in observations
    obs = LatentDelay(dayofweek_logit_ascert, delay_distribution)
    return obs
end

const negC = -1e15
"""
Soft minimum function for a smooth transition from `x -> x` to a maximum value of 1e15.
"""
_softmin(x) = -logaddexp(negC, -x)

function make_observation_model(pipeline::AbstractRtwithoutRenewalPipeline)
    default_params = make_default_params(pipeline)
    #Model for ascertainment based on day of the week
    dayofweek_logit_ascert = ascertainment_dayofweek(
        NegativeBinomialError(cluster_factor_prior = HalfNormal(default_params["cluster_factor"]));
        transform = (x, y) -> _softmin.(x .* y))

    #Default continuous-time model for latent delay in observations
    delay_distribution = make_delay_distribution(pipeline)
    #Model for latent delay in observations
    obs = LatentDelay(dayofweek_logit_ascert, delay_distribution)
    return obs
end
