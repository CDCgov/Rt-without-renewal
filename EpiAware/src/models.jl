@model function log_infections(
    y_t,
    epimodel::EpiModel,
    latent_process;
    latent_process_priors,
    transform_function = exp,
    n_generate_ahead = 0,
    pos_shift = 1e-6,
    neg_bin_cluster_factor = missing,
    neg_bin_cluster_factor_prior = Gamma(3, 0.05 / 3),
)
    #Prior

    neg_bin_cluster_factor ~ Gamma(3, 0.05 / 3)

    #Latent process
    time_steps = length(y_t) + n_generate_ahead

    @submodel _I_t, latent_process_parameters = latent_process(data_length; latent_process_priors=latent_process_priors)

    #Transform into infections
    I_t = transform_function.(_I_t)

    #Predictive distribution
    mean_case_preds = epimodel.delay_kernel * I_t
    case_pred_dists = mean_case_preds .+ pos_shift .|> μ -> mean_cc_neg_bin(μ, α)

    #Likelihood
    y_t ~ arraydist(case_pred_dists)

    #Generate quantities
    return (; I_t, latent_process_parameters)
end
