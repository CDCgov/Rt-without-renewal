"""
Constructs and returns a latent model based on the provided `inference_config` and `pipeline`.
The purpose of this function is to make adjustments to the latent model based on the
full `inference_config` provided.

The `pipeline` argument is used for dispatch purposes.

The prior decisions are based on the target standard deviation and autocorrelation of the latent process,
which are determined by the infection generating process (igp) and whether the latent process is stationary or non-stationary
via the `_make_target_std_and_autocorr` function.


# Returns
- A latent model object which can be one of `DiffLatentModel`, `AR`, or `RandomWalk` depending on the `latent_model_name` and `igp` specified in `inference_config`.
"""
function remake_latent_model(
        inference_config::Dict, pipeline::AbstractRtwithoutRenewalPipeline)
    #Baseline choices
    prior_dict = make_model_priors(pipeline)
    igp = inference_config["igp"]
    latent_model_name = inference_config["latent_namemodels"].first
    target_std, target_autocorr = latent_model_name == "ar" ?
                                  _make_target_std_and_autocorr(igp; stationary = true) :
                                  _make_target_std_and_autocorr(igp; stationary = false)

    return _implement_latent_process(
        target_std, target_autocorr, latent_model_name, pipeline)
end

"""
This function sets the target standard deviation for an infection generating process (igp)
based on whether the latent process representation of its dynamics are stationary or non-stationary.

## Stationary Processes

- For Renewal process `log(R_t)` in the long run a fluctuation of 0.75 (e.g. ~ 75% of the mean) is not unexpected.
- For Exponential Growth Rate process `r_t` in the long run a fluctuation of 0.1 is not unexpected e.g. going from
`rt = 0.1` (7 day doubling time) to `rt = -0.1` (7 day halving time) is a 0.1 fluctuation.
- For Direct Infections process `log(I_t)` in the long run a fluctuation of 1.0 (i.e an order of magnitude) is not unexpected.

For stationary Direct Infections process the autocorrelation is expected to be fairly high at 0.5,
because persistence in residual away from mean is expected. Otherwise, the autocorrelation is expected to be 0.1.

## Non-Stationary Processes

For Renewal process `log(R_t)` in a single time step a fluctuation of 0.025 (e.g. ~ 2.5% of the mean) is not unexpected.
For Exponential Growth Rate process `r_t` in a single time step a fluctuation of 0.005 is not unexpected.
For Direct Infections process `log(I_t)` in a single time step a fluctuation of 0.025 is not unexpected.

The autocorrelation is expected to be 0.1.
"""
function _make_target_std_and_autocorr(igp; stationary::Bool)
    if igp == Renewal
        return stationary ? (0.75, 0.1) : (0.025, 0.1)
    elseif igp == ExpGrowthRate
        return stationary ? (0.1, 0.1) : (0.005, 0.1)
    elseif igp == DirectInfections
        return stationary ? (1.0, 0.5) : (0.025, 0.1)
    end
end

"""
Constructs and returns a latent model based on an approximation to the specified target standard deviation and autocorrelation.

NB: The stationary variance of an AR(1) process is given by `σ² = σ²_ε / (1 - ρ²)` where `σ²_ε` is the variance of the noise and `ρ` is the autocorrelation.
The approximation here are based on `E[1/(1 - ρ²)`] ≈ 1 / (1 - E[ρ²])` which only holds for fairly tight distributions of `ρ`.
However, for priors this should get the expected order of magnitude.

# Models
- `"diff_ar"`: Constructs a `DiffLatentModel` with an autoregressive (AR) process.
- `"ar"`: Constructs an autoregressive (AR) process.
- `"rw"`: Constructs a random walk (RW) process.

"""
function _implement_latent_process(
        target_std, target_autocorr, latent_model_name, pipeline; beta_eff_sample_size = 10)
    prior_dict = make_model_priors(pipeline)
    damp_prior = Beta(target_autocorr * beta_eff_sample_size,
        (1 - target_autocorr) * beta_eff_sample_size)
    corr_corrected_noise_std = HalfNormal(target_std * sqrt(1 - target_autocorr^2))
    noise_std = HalfNormal(target_std)
    init_prior = prior_dict["transformed_process_init_prior"]
    if latent_model_name == "diff_ar"
        _ar = AR(damp_priors = [damp_prior],
            std_prior = corr_corrected_noise_std,
            init_priors = [init_prior])
        diff_ar = DiffLatentModel(;
            model = _ar, init_priors = [init_prior])
        return diff_ar
    elseif latent_model_name == "ar"
        ar = AR(damp_priors = [damp_prior],
            std_prior = corr_corrected_noise_std,
            init_priors = [init_prior])
        return ar
    elseif latent_model_name == "rw"
        rw = RandomWalk(
            std_prior = noise_std,
            init_prior = init_prior)
        return rw
    end
end

"""
Pass through fallback dispatch.
"""
function remake_latent_model(inference_config::Dict, pipeline::AbstractEpiAwarePipeline)
    inference_config["latent_namemodels"].second
end
