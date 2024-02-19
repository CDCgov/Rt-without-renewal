function default_delay_obs_priors()
    return (neg_bin_cluster_factor_prior = Gamma(3, 0.05 / 3),)
end

@model function delay_observations(
    y_t,
    I_t,
    epimodel::AbstractEpiModel;
    observation_process_priors = default_delay_obs_priors(),
    pos_shift = 1e-6,
)
    #Parameters
    neg_bin_cluster_factor ~ observation_process_priors.neg_bin_cluster_factor_prior

    #Predictive distribution
    case_pred_dists =
        (epimodel.data.delay_kernel * I_t) .+ pos_shift .|>
        μ -> mean_cc_neg_bin(μ, neg_bin_cluster_factor)

    #Likelihood
    y_t ~ arraydist(case_pred_dists)

    return y_t, (; neg_bin_cluster_factor,)
end
