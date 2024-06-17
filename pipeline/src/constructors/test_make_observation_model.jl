using Test

@testset "make_observation_model" begin
    # Mock pipeline object
    struct MockPipeline <: AbstractEpiAwarePipeline
    end

    # Test case 1: Check if the returned object is of type LatentDelay
    @testset "Returned object type" begin
        obs = make_observation_model(MockPipeline())
        @test typeof(obs) == LatentDelay
    end

    # Test case 2: Check if the default parameters are correctly passed to ascertainment_dayofweek
    @testset "Default parameters" begin
        obs = make_observation_model(MockPipeline())
        @test obs.dayofweek_logit_ascert.cluster_factor_prior ==
              HalfNormal(make_default_params(MockPipeline())["cluster_factor"])
    end

    # Test case 3: Check if the delay distribution is correctly constructed
    @testset "Delay distribution" begin
        obs = make_observation_model(MockPipeline())
        @test typeof(obs.delay_distribution) == DelayDistribution
    end
end
