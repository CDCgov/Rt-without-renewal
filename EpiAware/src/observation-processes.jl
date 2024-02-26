function default_delay_obs_priors()
    return (:neg_bin_cluster_factor_prior => Gamma(3, 0.05 / 3),) |> Dict
end

@model function delay_observations(
        y_t,
        I_t,
        epimodel::AbstractEpiModel;
        neg_bin_cluster_factor_prior,
        pos_shift
)
    #Parameters
    neg_bin_cluster_factor ~ neg_bin_cluster_factor_prior

    #Predictive distribution
    case_pred_dists = (epimodel.data.delay_kernel * I_t) .+ pos_shift .|>
                      μ -> mean_cc_neg_bin(μ, neg_bin_cluster_factor)

    #Likelihood
    y_t ~ arraydist(case_pred_dists)

    return y_t, (; neg_bin_cluster_factor,)
end

"""
    struct ObservationModel{F <: Function, D<:Distribution}

A struct representing an observation model.

# Fields
- `observation_model`: The observation model function.
- `observation_model_priors`: A dictionary of prior distributions for the observation model parameters.

"""
struct ObservationModel{F <: Function, D <: Distribution}
    observation_model::F
    observation_model_priors::Dict{Symbol, D}
end

"""
    delay_observations_model(; latent_process_priors = default_rw_priors())

Create an `ObservationModel` struct reflecting a delayed observation process with optional priors.

# Arguments
- `latent_process_priors`: Optional priors for the delayed observation process.

# Returns
- `ObservationModel`: An observation model with delayed observations.

"""
function delay_observations_model(; observation_model_priors = default_delay_obs_priors())
    ObservationModel(delay_observations, observation_model_priors)
end
