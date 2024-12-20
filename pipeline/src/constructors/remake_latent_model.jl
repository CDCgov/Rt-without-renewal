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
    default_latent_model = inference_config["latent_namemodels"].second
    target_std, target_autocorr = default_latent_model isa AR ?
                                  _make_target_std_and_autocorr(igp; stationary = true) :
                                  _make_target_std_and_autocorr(igp; stationary = false)

    return _implement_latent_process(
        target_std, target_autocorr, default_latent_model, pipeline)
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
function _make_target_std_and_autocorr(::Type{Renewal}; stationary::Bool)
    return stationary ? (0.75, 0.1) : (0.025, 0.1)
end

function _make_target_std_and_autocorr(::Type{ExpGrowthRate}; stationary::Bool)
    return stationary ? (0.1, 0.1) : (0.005, 0.1)
end

function _make_target_std_and_autocorr(::Type{DirectInfections}; stationary::Bool)
    return stationary ? (1.0, 0.5) : (0.025, 0.1)
end

function _make_new_prior_dict(target_std, target_autocorr,
        pipeline::AbstractRtwithoutRenewalPipeline; beta_eff_sample_size)
    #Get default priors
    prior_dict = make_model_priors(pipeline)
    #Adjust priors based on target autocorrelation and standard deviation
    damp_prior = Beta(target_autocorr * beta_eff_sample_size,
        (1 - target_autocorr) * beta_eff_sample_size)
    corr_corrected_noise_prior = HalfNormal(target_std * sqrt(1 - target_autocorr^2))
    noise_prior = HalfNormal(target_std)
    init_prior = prior_dict["transformed_process_init_prior"]
    return Dict(
        "transformed_process_init_prior" => init_prior,
        "corr_corrected_noise_prior" => corr_corrected_noise_prior,
        "noise_prior" => noise_prior,
        "damp_param_prior" => damp_prior
    )
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
        target_std, target_autocorr, default_latent_model, pipeline; beta_eff_sample_size = 10)
    prior_dict = make_model_priors(pipeline)
    new_priors = _make_new_prior_dict(
        target_std, target_autocorr, pipeline; beta_eff_sample_size)

    return _make_latent(default_latent_model, new_priors)
end

function _make_latent(::AR, new_priors)
    damp_prior = new_priors["damp_param_prior"]
    corr_corrected_noise_std = new_priors["corr_corrected_noise_prior"]
    init_prior = new_priors["transformed_process_init_prior"]
    return AR(damp_priors = [damp_prior],
        std_prior = corr_corrected_noise_std,
        init_priors = [init_prior])
end

function _make_latent(::DiffLatentModel, new_priors)
    init_prior = new_priors["transformed_process_init_prior"]
    ar = _make_latent(AR(), new_priors)
    return DiffLatentModel(; model = ar, init_priors = [init_prior])
end

function _make_latent(::RandomWalk, new_priors)
    noise_std = new_priors["noise_prior"]
    init_prior = new_priors["transformed_process_init_prior"]
    return RandomWalk(std_prior = noise_std, init_prior = init_prior)
end

"""
Pass through fallback dispatch.
"""
function remake_latent_model(inference_config::Dict, pipeline::AbstractEpiAwarePipeline)
    inference_config["latent_namemodels"].second
end
