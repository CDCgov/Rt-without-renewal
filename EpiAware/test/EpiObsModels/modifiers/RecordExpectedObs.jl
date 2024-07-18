@testitem "RecordExpectedObs constructor works as expected" begin
    model = RecordExpectedObs(PoissonError())
    @test typeof(model) <: RecordExpectedObs
    @test typeof(model) <: AbstractTuringObservationErrorModel
    @test typeof(model.model) <: PoissonError
end

@testitem "RecordExpectedObs observation_error works as expected" begin
    using EpiAware, Turing
    mdl = RecordExpectedObs(NegativeBinomialError())
    gen_obs = generate_observations(mdl, missing, fill(100, 1))
    samples = sample(gen_obs, Prior(), 10)
    @test all(get(samples, :exp_y_t).exp_y_t .== 100)
end
