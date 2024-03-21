@testitem "EpiProblem Tests" begin
    using Distributions
    # Define test inputs
    data = EpiData([0.2, 0.3, 0.5], exp)
    epi_model = DirectInfections(data, Normal())
    latent_model = RandomWalk()
    obs_model = LatentDelay(
        NegativeBinomialError(), [0.2, 0.3, 0.5]
    )

    tspan = (0, 365)

    # Create an instance of EpiProblem
    problem = EpiProblem(epi_model, latent_model, obs_model, tspan)

    @test typeof(problem) <: EpiProblem
    @test typeof(problem.epi_model) <: DirectInfections
    @test typeof(problem.latent_model) <: RandomWalk
    @test typeof(problem.observation_model) <: LatentDelay
    @test problem.tspan == (0, 365)
end
