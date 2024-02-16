@model function make_epi_inference_model(
    y_t,
    epimodel::AbstractEpiModel,
    latent_process;
    latent_process_priors,
    pos_shift = 1e-6,
    neg_bin_cluster_factor = missing,
    neg_bin_cluster_factor_prior = Gamma(3, 0.05 / 3),
)
    #Prior
    neg_bin_cluster_factor ~ neg_bin_cluster_factor_prior

    #Latent process
    time_steps = epimodel.data.time_horizon
    @submodel latent_process, latent_process_aux =
        latent_process(time_steps; latent_process_priors = latent_process_priors)

    #Transform into infections
    I_t = epimodel(latent_process, latent_process_aux)

    #Predictive distribution
    case_pred_dists =
        (epimodel.data.delay_kernel * I_t) .+ pos_shift .|>
        μ -> mean_cc_neg_bin(μ, neg_bin_cluster_factor)

    #Likelihood
    y_t ~ arraydist(case_pred_dists)

    #Generate quantities
    return (; I_t, latent_process, latent_process_aux)
end
