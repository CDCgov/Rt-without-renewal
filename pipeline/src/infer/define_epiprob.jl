"""
Create an `EpiData` object based on the provided generation interval mean and standard
deviation by assuming a gamma distribution.

# Arguments
- `gi_mean::Float64`: Mean of the generation interval.
- `gi_std::Float64`: Standard deviation of the generation interval.
- `transformation`: A transformation function to be applied
    (default is `EpiAwarePipeline.oneexpy` a custom implementation of `exp`).

# Returns
- `model_data::EpiData`: An `EpiData` object containing the generation interval distribution
    and transformation.

"""
function _make_epidata(gi_mean, gi_std; transformation = EpiAwarePipeline.oneexpy)
    shape = (gi_mean / gi_std)^2
    scale = gi_std^2 / gi_mean
    gen_distribution = Gamma(shape, scale)

    model_data = EpiData(
        gen_distribution = gen_distribution, transformation = transformation)
    return model_data
end

"""
Create an `EpiProblem` object based on the provided `InferenceConfig`.

# Arguments
- `config::InferenceConfig`: An instance of the `InferenceConfig` type.

# Returns
- `epi_prob::EpiProblem`: An `EpiProblem` object representing the defined epidemiological problem.

"""
function define_epiprob(config::InferenceConfig)
    model_data = _make_epidata(
        config.gi_mean, config.gi_std; transformation = config.transformation)
    #Build the epidemiological model
    epi = config.igp(data = model_data, initialisation_prior = config.log_I0_prior)

    epi_prob = EpiProblem(epi_model = epi,
        latent_model = config.latent_model,
        observation_model = config.observation_model,
        tspan = config.tspan)

    return epi_prob
end
