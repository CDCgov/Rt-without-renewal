"""
    log_infections(y_t, epimodel::EpiModel, latent_process;
                   latent_process_priors,
                   transform_function = exp,
                   n_generate_ahead = 0,
                   pos_shift = 1e-6,
                   neg_bin_cluster_factor = missing,
                   neg_bin_cluster_factor_prior = Gamma(3, 0.05 / 3))

A Turing model for Log-infections undelying observed epidemiological data.

This function defines a log-infections model for epidemiological data.
It takes the observed data `y_t`, an `EpiModel` object `epimodel`, and a `latent_process`
model. It also accepts optional arguments for the `latent_process_priors`, `transform_function`,
`n_generate_ahead`, `pos_shift`, `neg_bin_cluster_factor`, and `neg_bin_cluster_factor_prior`.

## Arguments
- `y_t`: Observed data.
- `epimodel`: Epidemiological model.
- `latent_process`: Latent process model.
- `latent_process_priors`: Priors for the latent process model.
- `transform_function`: Function to transform the latent process into infections. Default is `exp`.
- `n_generate_ahead`: Number of time steps to generate ahead. Default is `0`.
- `pos_shift`: Positive shift to avoid zero values. Default is `1e-6`.
- `neg_bin_cluster_factor`: Missing value for the negative binomial cluster factor. Default is `missing`.
- `neg_bin_cluster_factor_prior`: Prior distribution for the negative binomial cluster factor. Default is `Gamma(3, 0.05 / 3)`.

## Returns
A named tuple containing the generated quantities `I_t` and `latent_process_parameters`.
"""
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
    neg_bin_cluster_factor ~ neg_bin_cluster_factor_prior

    #Latent process
    time_steps = length(y_t) + n_generate_ahead
    @submodel _I_t, latent_process_parameters =
        latent_process(time_steps; latent_process_priors = latent_process_priors)

    #Transform into infections
    I_t = transform_function.(_I_t)

    #Predictive distribution
    case_pred_dists =
        (epimodel.delay_kernel * I_t) .+ pos_shift .|> μ -> mean_cc_neg_bin(μ, α)

    #Likelihood
    y_t ~ arraydist(case_pred_dists)

    #Generate quantities
    return (; I_t, latent_process_parameters)
end
