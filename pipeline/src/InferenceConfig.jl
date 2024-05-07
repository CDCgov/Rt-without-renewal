@kwdef struct InferenceConfig{T <: Real, F <: Function}
    "Assumed generation interval distribution mean."
    gi_mean::T
    "Assumed generation interval distribution std."
    gi_std::T
    "Infection-generating model type."
    igp::UnionAll
    "Latent model type."
    latent_model::UnionAll
    "Case data"
    case_data::Vector{Integer}
    "Time to fit on"
    tspan::Tuple{Integer, Integer}
    "Inference method."
    epimethod::AbstractEpiMethod
    "Maximum next generation interval when discretized."
    D_gen::T = T(60.0)
    "Transformation function"
    transformation::F = exp
    "Delay distribution: Default is Gamma(4, 5/4)."
    delay_distribution::Distribution = Gamma(4, 5 / 4)
    "Maximum delay when discretized. Default is 15 days."
    D_obs::T = T(15.0)
    "Prior for log initial infections. Default is Normal(4.6, 1e-5)."
    log_I0_prior::Distribution = Normal(log(100.0), 1e-5)
    "Prior for negative binomial cluster factor. Default is HalfNormal(0.1)."
    cluster_factor_prior::Distribution = HalfNormal(0.1)
end

function simulate_or_infer(config::InferenceConfig)
    #Define infection-generating model
    shape = (config.gi_mean / config.gi_std)^2
    scale = config.gi_std^2 / config.gi_mean
    gen_distribution = Gamma(shape, scale)

    #Define the infection-generating process
    model_data = EpiData(gen_distribution = gen_distribution, D_gen = config.D_gen,
        transformation = config.transformation)

    epi = config.igp(model_data, config.log_I0_prior)

    #Define the infection conditional observation distribution
    obs = LatentDelay(
        NegativeBinomialError(cluster_factor_prior = config.cluster_factor_prior),
        config.delay_distribution; D = config.D_obs)

    #Define the EpiProblem
    epi_prob = EpiProblem(epi_model = epi,
        latent_model = config.latent_model,
        observation_model = obs,
        tspan = config.tspan)

    idxs = config.tspan[1]:config.tspan[2]
    #Return the sampled infections and observations
    inference_results = apply_method(epi_prob,
        config.inference_method,
        (y_t = config.case_data[idxs],)
    )
    return inference_results
end
