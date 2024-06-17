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
struct InferenceConfig{T, F, I, L, O, E}
    gi_mean::T
    gi_std::T
    igp::I
    latent_model::L
    observation_model::O
    case_data::Union{Vector{Union{Integer, Missing}}, Missing}
    tspan::Tuple{Integer, Integer}
    epimethod::E
    transformation::F
    log_I0_prior::Distribution

    function InferenceConfig(igp, latent_model, observation_model; gi_mean, gi_std,
            case_data, tspan, epimethod, transformation = exp, log_I0_prior)
        new{typeof(gi_mean), typeof(transformation),
            typeof(igp), typeof(latent_model), typeof(observation_model), typeof(epimethod)}(
            gi_mean, gi_std, igp, latent_model, observation_model,
            case_data, tspan, epimethod, transformation, log_I0_prior)
    end

    function InferenceConfig(
            inference_config::Dict; case_data, tspan, epimethod)
        InferenceConfig(
            inference_config["igp"],
            inference_config["latent_namemodels"].second,
            inference_config["observation_model"];
            gi_mean = inference_config["gi_mean"],
            gi_std = inference_config["gi_std"],
            case_data = case_data,
            tspan = tspan,
            epimethod = epimethod,
            log_I0_prior = inference_config["log_I0_prior"]
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
    epi_prob = define_epiprob(config)
    idxs = config.tspan[1]:config.tspan[2]

    #Return the sampled infections and observations
    y_t = ismissing(config.case_data) ? missing : config.case_data[idxs]
    inference_results = apply_method(epi_prob,
        config.epimethod,
        (y_t = y_t,);
    )
    return Dict("inference_results" => inference_results, "epiprob" => epi_prob)
end
