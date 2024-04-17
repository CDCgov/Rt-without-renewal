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

@testitem "generate_epiaware EpiProblem method" begin
    struct TestEpiModel <: AbstractEpiModel end

    function EpiAware.EpiAwareBase.generate_epiaware(
            y_t, time_steps, epi_model::TestEpiModel; latent_model, observation_model)
        return "hello"
    end

    struct TestLatentModel <: AbstractLatentModel end
    struct TestObservationModel <: AbstractObservationModel end

    tspan = (0, 365)
    data = (y_t = missing,)
    problem = EpiProblem(
        TestEpiModel(), TestLatentModel(), TestObservationModel(), tspan
    )

    @test generate_epiaware(problem, data) == "hello"
end
