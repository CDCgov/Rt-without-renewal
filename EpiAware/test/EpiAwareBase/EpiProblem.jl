@testitem "EpiProblem Tests" begin
    struct TestEpiModel <: AbstractEpiModel
    end
    struct TestLatentModel <: AbstractLatentModel
    end
    struct TestObservationModel <: AbstractObservationModel
    end

    tspan = (0, 365)
    problem = EpiProblem(
        TestEpiModel(), TestLatentModel(), TestObservationModel(), tspan
    )

    @test typeof(problem) <: EpiProblem
    @test typeof(problem.epi_model) <: TestEpiModel
    @test typeof(problem.latent_model) <: TestLatentModel
    @test typeof(problem.observation_model) <: TestObservationModel
    @test problem.tspan == (0, 365)
end
