@testitem "Aggregate constructor works as expected" begin
    weekly_agg = Aggregate(PoissonError(), [0, 0, 0, 0, 7, 0, 0])
    @test weekly_agg.model == PoissonError()
    @test weekly_agg.aggregation == [0, 0, 0, 0, 7, 0, 0]
    @test weekly_agg.present == [false, false, false, false, true, false, false]

    weekly_agg = Aggregate(model = PoissonError(), aggregation = [0, 0, 0, 0, 7, 0, 0])
    @test weekly_agg.model == PoissonError()
    @test weekly_agg.aggregation == [0, 0, 0, 0, 7, 0, 0]
end

@testitem "Aggregate generate_observations works as expected" begin
    using Turing
    struct TestObs <: AbstractTuringObservationModel end

    @model function EpiAwareBase.generate_observations(::TestObs, y_t, Y_t)
        return Y_t
    end
    weekly_agg = Aggregate(TestObs(), [0, 0, 0, 0, 7, 0, 0])
    gen_obs = generate_observations(weekly_agg, missing, fill(1, 28))
    draws = gen_obs()
    @test draws isa Vector{Int64}
    @test length(draws) == 28
    exp_draws = fill(0.0, 28)
    exp_draws[5] = 5.0
    exp_draws[12] = 7.0
    exp_draws[19] = 7.0
    exp_draws[26] = 7.0
    @test draws == exp_draws
end
