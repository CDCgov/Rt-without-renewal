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
        @test isapprox(mdl(), I_t, atol = 1e-3)
    end

    missing_I_t = vcat(missing, I_t)

    @testset "Test with leading missing expected observations" begin
        mdl = generate_observations(obs_model, missing_I_t, vcat(20, I_t))
        draw = mdl()
        @test draw[2:end] == I_t
        @test abs(draw[1] - 20) > 0
        @test isapprox(draw[1], 20, atol = 1e-3)
    end

    @testset "Test works with truncated expected observations" begin
        mdl = generate_observations(obs_model, fill(missing, 5), I_t[(end - 3):end])
        draw = mdl()
        @test all(map(zip(draw[(end - 3):end], I_t[(end - 3):end])) do (draw, I_t)
            isapprox(draw, I_t, atol = 1e-3)
        end)
        @test ismissing(draw[1])
    end

    @test_throws AssertionError generate_observations(obs_model, I_t, vcat(1, I_t))()
end
