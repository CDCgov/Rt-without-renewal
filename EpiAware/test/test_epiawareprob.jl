@testitem "EpiAwareProblem Tests" begin
    using Distributions
    # Define test inputs
    data = EpiData([0.2, 0.3, 0.5], exp)
    epi_model = DirectInfections(data, Normal())
    latent_model = RandomWalk(Normal(0.0, 1.0), truncated(Normal(0.0, 0.05), 0.0, Inf))
    delay_int = [0.2, 0.3, 0.5]
    time_horizon = 30
    obs_prior = default_delay_obs_priors()

    obs_model = DelayObservations(delay_int, time_horizon,
        obs_prior[:neg_bin_cluster_factor_prior])
    tspan = (0, 365)

    # Create an instance of EpiAwareProblem
    problem = EpiAwareProblem(epi_model, latent_model, obs_model, tspan)

    @test typeof(problem) <: EpiAwareProblem
    @test typeof(problem.epi_model) <: DirectInfections
    @test typeof(problem.latent_model) <: RandomWalk
    @test typeof(problem.observation_model) <: DelayObservations
    @test problem.tspan == (0, 365)
end
