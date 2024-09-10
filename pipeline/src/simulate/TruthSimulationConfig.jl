"""
A configuration struct for truth simulation to compare to inference.

NB: This config assumes Gamma distributed generation interval, specified by
mean and standard deviation.
"""
@kwdef struct TruthSimulationConfig{T <: Real, F <: Function}
    "True time-varying process. Default this is the time-varing reproductive
    number"
    truth_process::Vector{T}
    "True generation interval distribution mean."
    gi_mean::T
    "True generation interval distribution std."
    gi_std::T
    "True day of week relative ascertainment."
    logit_daily_ascertainment::Vector{T}
    "True cluster factor."
    cluster_factor::T
    "True initial infections."
    I0::T
    "Infection-generating model type. Default is `:Renewal`."
    igp::UnionAll = Renewal
    "Transformation function"
    transformation::F = exp
    "Delay distribution: Default is Gamma(4, 5/4)."
    delay_distribution::Distribution = Gamma(4, 5 / 4)
end

"""
Simulates or infers the truth process and observations based on the given configuration.

# Arguments
- `config::TruthSimulationConfig`: The configuration object containing the parameters for the simulation.

# Returns
A dictionary containing the sampled infections and observations, along with other relevant information.

"""
function simulate(config::TruthSimulationConfig)
    #Define infection-generating model
    shape = (config.gi_mean / config.gi_std)^2
    scale = config.gi_std^2 / config.gi_mean
    gen_distribution = Gamma(shape, scale)

    model_data = EpiData(gen_distribution = gen_distribution,
        transformation = config.transformation)

    #Sample infections NB: prior is arbitrary because I0 is fixed.
    epi = config.igp(model_data; initialisation_prior = Normal(log(config.I0), 0.01))

    inf_mdl = generate_latent_infs(epi, log.(config.truth_process)) |>
              mdl -> fix(mdl, (init_incidence = log(config.I0),))
    I_t = inf_mdl()

    #Define the infection conditional observation distribution

    #Model for day-of-week relative ascertainment on logit-scale
    #NB: prior is arbitrary because cluster factor is fixed.
    dayofweek_logit_ascert = ascertainment_dayofweek(NegativeBinomialError(cluster_factor_prior = HalfNormal(config.cluster_factor)))

    #Model for latent delay in observations
    obs = LatentDelay(dayofweek_logit_ascert, config.delay_distribution)

    #Sample observations with fixed values of underlying logit relative ascertainment
    obs_model = generate_observations(obs, missing, I_t) |>
                mdl -> fix(mdl,
        (std = 1.0, cluster_factor = config.cluster_factor,
            ϵ_t = config.logit_daily_ascertainment))

    y_t = obs_model() .|> (y -> ismissing(y) ? missing : Int64(y)) |>
          Vector{Union{Missing, Int64}}

    #Return the sampled infections and observations

    return Dict("I_t" => I_t, "y_t" => y_t,
        "truth_process" => config.truth_process,
        "truth_gi_mean" => config.gi_mean,
        "truth_gi_std" => config.gi_std,
        "truth_daily_ascertainment" => 7 * softmax(config.logit_daily_ascertainment),
        "truth_I0" => config.I0,
        "truth_cluster_factor" => config.cluster_factor
    )
end
