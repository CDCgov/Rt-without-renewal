"""
Inference configuration struct for specifying the parameters and models used in the inference process.

# Fields
- `gi_mean::T`: Assumed generation interval distribution mean.
- `gi_std::T`: Assumed generation interval distribution standard deviation.
- `igp::I`: Infection-generating model type.
- `latent_model::L`: Latent model type.
- `observation_model::O`: Observation model type.
- `case_data::Union{Vector{Union{Integer, Missing}}, Missing}`: Case data.
- `tspan::Tuple{Integer, Integer}`: Time range to fit on.
- `epimethod::E`: Inference method.
- `transformation::F`: Transformation function.
- `log_I0_prior::Distribution`: Prior for log initial infections. Default is `Normal(log(100.0), 1e-5)`.

# Constructors
- `InferenceConfig(igp, latent_model, observation_model; gi_mean, gi_std, case_data, tspan, epimethod, transformation = exp)`: Constructs an `InferenceConfig` object with the specified parameters.
- `InferenceConfig(inference_config::Dict; case_data, tspan, epimethod)`: Constructs an `InferenceConfig` object from a dictionary of configuration values.

"""
struct InferenceConfig{T, F, IGP, L, O, E, D <: Distribution, X <: Integer}
    gi_mean::T
    gi_std::T
    igp::IGP
    latent_model::L
    observation_model::O
    case_data::Union{Vector{Union{Integer, Missing}}, Missing}
    truth_I_t::Vector{T}
    truth_I0::T
    tspan::Tuple{Integer, Integer}
    epimethod::E
    transformation::F
    log_I0_prior::D
    lookahead::X

    function InferenceConfig(igp, latent_model, observation_model; gi_mean, gi_std,
            case_data, truth_I_t, truth_I0, tspan, epimethod,
            transformation = exp, log_I0_prior, lookahead)
        new{typeof(gi_mean), typeof(transformation),
            typeof(igp), typeof(latent_model), typeof(observation_model),
            typeof(epimethod), typeof(log_I0_prior), typeof(lookahead)}(
            gi_mean, gi_std, igp, latent_model, observation_model,
            case_data, truth_I_t, truth_I0, tspan, epimethod, transformation, log_I0_prior, lookahead)
    end

    function InferenceConfig(
            inference_config::Dict; case_data, truth_I_t, truth_I0, tspan, epimethod)
        InferenceConfig(
            inference_config["igp"],
            inference_config["latent_namemodels"].second,
            inference_config["observation_model"];
            gi_mean = inference_config["gi_mean"],
            gi_std = inference_config["gi_std"],
            case_data = case_data,
            truth_I_t = truth_I_t,
            truth_I0 = truth_I0,
            tspan = tspan,
            epimethod = epimethod,
            log_I0_prior = inference_config["log_I0_prior"],
            lookahead = inference_config["lookahead"]
        )
    end
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
    epiprob = define_epiprob(config)
    idxs = config.tspan[1]:config.tspan[2]

    #Return the sampled infections and observations
    y_t = ismissing(config.case_data) ? missing : config.case_data[idxs]
    inference_results = apply_method(epiprob,
        config.epimethod,
        (y_t = y_t,);
    )

    forecast_results = generate_forecasts(
        inference_results.samples, inference_results.data, epiprob, config.lookahead)

    epidata = epiprob.epi_model.data
    score_results = summarise_crps(config, inference_results, forecast_results, epidata)

    return Dict("inference_results" => inference_results,
        "epiprob" => epiprob, "inference_config" => config,
        "forecast_results" => forecast_results, "score_results" => score_results)
end
