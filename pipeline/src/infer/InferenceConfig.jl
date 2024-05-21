"""
The `InferenceConfig` struct represents the configuration parameters for the
    inference process from case data.

## Constructors
- `InferenceConfig(igp, latent_model; gi_mean, gi_std, case_data, tspan,
    epimethod, delay_distribution = Gamma(4, 5 / 4), log_I0_prior = Normal(log(100.0), 1e-5),
    cluster_factor_prior = HalfNormal(0.1), transformation = exp)`: Create a new
        `InferenceConfig` object with the specified parameters.

"""
struct InferenceConfig{T, F, I, L, E}
    "Assumed generation interval distribution mean."
    gi_mean::T
    "Assumed generation interval distribution std."
    gi_std::T
    "Infection-generating model type."
    igp::I
    "Latent model type."
    latent_model::L
    "Case data"
    case_data::Union{Vector{Integer}, Missing}
    "Time to fit on"
    tspan::Tuple{Integer, Integer}
    "Inference method."
    epimethod::E
    "Maximum next generation interval when discretized."
    D_gen::T
    "Transformation function"
    transformation::F
    "Delay distribution: Default is Gamma(4, 5/4)."
    delay_distribution::Distribution
    "Maximum delay when discretized. Default is 15 days."
    D_obs::T
    "Prior for log initial infections. Default is Normal(4.6, 1e-5)."
    log_I0_prior::Distribution
    "Prior for negative binomial cluster factor. Default is HalfNormal(0.1)."
    cluster_factor_prior::Distribution

    function InferenceConfig(igp, latent_model; gi_mean, gi_std, case_data, tspan,
            epimethod, delay_distribution = Gamma(4, 5 / 4),
            log_I0_prior = Normal(log(100.0), 1e-5),
            cluster_factor_prior = HalfNormal(0.1),
            transformation = exp)
        D_gen = gi_mean + 4 * gi_std
        D_obs = mean(delay_distribution) + 4 * std(delay_distribution)

        new{typeof(gi_mean), typeof(transformation),
            typeof(igp), typeof(latent_model), typeof(epimethod)}(
            gi_mean, gi_std, igp, latent_model, case_data, tspan, epimethod,
            D_gen, transformation, delay_distribution, D_obs, log_I0_prior, cluster_factor_prior)
    end

    function InferenceConfig(inference_config::Dict, case_data)
        InferenceConfig(
            inference_config["igp"], inference_config["latent_namemodels"].second;
            gi_mean = inference_config["gi_mean"],
            gi_std = inference_config["gi_std"],
            case_data = case_data,
            tspan = tspan,
            epimethod = inference_method
        )
    end
end

"""
Create an `EpiProblem` object based on the provided `InferenceConfig`.

# Arguments
- `config::InferenceConfig`: An instance of the `InferenceConfig` type.

# Returns
- `epi_prob::EpiProblem`: An `EpiProblem` object representing the defined epidemiological problem.

"""
function define_epiprob(config::InferenceConfig)
    shape = (config.gi_mean / config.gi_std)^2
    scale = config.gi_std^2 / config.gi_mean
    gen_distribution = Gamma(shape, scale)

    model_data = EpiData(gen_distribution = gen_distribution, D_gen = config.D_gen,
        transformation = config.transformation)

    epi = config.igp(model_data, config.log_I0_prior)

    obs = LatentDelay(
        NegativeBinomialError(cluster_factor_prior = config.cluster_factor_prior),
        config.delay_distribution; D = config.D_obs)

    epi_prob = EpiProblem(epi_model = epi,
        latent_model = config.latent_model,
        observation_model = obs,
        tspan = config.tspan)

    return epi_prob
end

"""
This method makes inference on the underlying parameters of the model specified
in the `InferenceConfig` object `config`.

# Arguments
- `config::InferenceConfig`: The configuration object containing the case data
to make inference on and model configuration.

# Returns
- `inference_results`: The results of the simulation or inference.

"""
function infer(config::InferenceConfig)
    #Define the EpiProblem
    epi_prob = define_epiprob(config)
    idxs = config.tspan[1]:config.tspan[2]

    #Return the sampled infections and observations
    y_t = ismissing(config.case_data) ? missing : config.case_data[idxs]
    inference_results = apply_method(epi_prob,
        config.epimethod,
        (y_t = y_t,)
    )
    return Dict("inference_results" => inference_results)
end
