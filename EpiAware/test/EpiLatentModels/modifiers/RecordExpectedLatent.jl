@testitem "RecordExpectedLatent constructor works as expected" begin
    model = RecordExpectedLatent(FixedIntercept(0.1))
    @test typeof(model) <: RecordExpectedLatent
    @test typeof(model) <: AbstractTuringLatentModel
    @test typeof(model.model) <: FixedIntercept
end

@testitem "RecordExpectedLatent observation_error works as expected" begin
    using EpiAware, Turing
    mdl = RecordExpectedLatent(FixedIntercept(0.1))
    gen_latent = generate_latent(mdl, 1)
    samples = sample(gen_latent, Prior(), 10; progress = false)
    @test all(get(samples, :exp_latent).exp_latent .== 0.1)
end
