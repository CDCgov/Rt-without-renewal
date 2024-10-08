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

    model_data = EpiData(
        gen_distribution = gen_distribution, transformation = config.transformation)
    #Build the epidemiological model
    epi = config.igp(data = model_data, initialisation_prior = config.log_I0_prior)

    epi_prob = EpiProblem(epi_model = epi,
        latent_model = config.latent_model,
        observation_model = config.observation_model,
        tspan = config.tspan)

    return epi_prob
end
