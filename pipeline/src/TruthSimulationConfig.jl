"""
A configuration struct for truth simulation to compare to inference.
"""
@kwdef struct TruthSimulationConfig{T <: Real, F <: Function}
    "True time-varying process. Default this is the time-varing reproductive
    number"
    truth_process::Vector{T}
    "True generation interval distribution."
    generation_distribution::Distribution
    "Infection-generating model type. Default is `:Renewal`."
    igp::UnionAll = Renewal
    "Maximum next generation interval when discretized. Default is 21 days."
    D_gen::T = 21.0
    "Transformation function"
    transformation::F = exp
    "Delay distribution: Default is Gamma(4, 5/4)."
    delay_distribution::Distribution = Gamma(4, 5 / 4)
    "Maximum delay when discretized. Default is 15 days."
    D_obs::T = 15.0
end

"""
    simulate_or_infer(config::TruthSimulationConfig)

Simulates or infers the truth process and observations based on the given configuration.

# Arguments
- `config::TruthSimulationConfig`: The configuration object containing the parameters for the simulation.

# Returns
A dictionary containing the sampled infections and observations, along with other relevant information.

"""
function simulate_or_infer(config::TruthSimulationConfig)
    #Define infection-generating model
    model_data = EpiData(gen_distribution = config.generation_distribution,
        D_gen = config.D_gen,
        transformation = config.transformation)

    log_I0_prior = Normal(log(10.0), 1e-5)
    epi = config.igp(model_data, log_I0_prior)

    # Sample infections
    inf_mdl = generate_latent_infs(epi, log.(config.truth_process))
    I_t = inf_mdl()

    #Define the infection conditional observation distribution
    obs = LatentDelay(NegativeBinomialError(), config.delay_distribution; D = config.D_obs)

    #Sample observations
    obs_model = generate_observations(obs, missing, I_t)
    yt, θ = obs_model()

    #Return the sampled infections and observations

    return Dict("I_t" => I_t, "y_t" => yt, "cluster_factor" => θ.cluster_factor,
        "truth_process" => config.truth_process,
        "truth_gi_mean" => mean(config.generation_distribution),
        "truth_gi_std" => std(config.generation_distribution))
end

"""
Method for `DrWatson.savename` which returns mean and standard deviation of the generation
interval distribution for truth simulation
"""
function DrWatson.savename(config::TruthSimulationConfig, suffix::String = "")
    dist = config.generation_distribution
    str = "gi_mean_" * string(mean(dist)) * "_gi_std_" * string(std(dist)) * suffix
    return str::String
end

"""
"""
function DrWatson.savename(
        prefix::String, config::TruthSimulationConfig, suffix::String = "")
    prefix * savename(config::TruthSimulationConfig, suffix)
end
