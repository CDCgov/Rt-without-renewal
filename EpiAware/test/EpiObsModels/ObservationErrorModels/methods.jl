@testitem "Test specific generate_observations" begin
    using Distributions: Normal
    struct TestObs <: AbstractTuringObservationErrorModel end

    function EpiObsModels.observation_error(model::TestObs, Y_t)
        Normal(Y_t, 1e-6)
    end

    obs_model = TestObs()

    I_t = [10.0, 20.0, 30.0, 40.0, 50.0]

    @testset "Test with entirely missing data" begin
        mdl = generate_observations(obs_model, missing, I_t)
        @test isapprox(mdl()[1], I_t, atol = 1e-3)
    end

    missing_I_t = vcat(missing, I_t)

    @testset "Test with leading missing expected observations" begin
        mdl = generate_observations(obs_model, missing_I_t, vcat(20, I_t))
        draw = mdl()[1]
        @test draw[2:end] == I_t
        @test abs(draw[1] - 20) > 0
        @test isapprox(draw[1], 20, atol = 1e-3)
    end

    @test_throws AssertionError generate_observations(obs_model, vcat(1, I_t), I_t)()
end
