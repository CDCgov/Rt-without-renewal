
# Test the InferenceConfig struct constructor
@testset "InferenceConfig: constructor function" begin
    using Distributions, EpiAwarePipeline, EpiAware

    struct TestLatentModel <: AbstractLatentModel
    end

    struct TestMethod <: AbstractEpiMethod
    end

    gi_mean = 3.0
    gi_std = 2.0
    igp = Renewal
    latent_model = TestLatentModel()
    epimethod = TestMethod()
    case_data = [10, 20, 30, 40, 50]
    tspan = (1, 5)

    config = InferenceConfig(igp, latent_model;
        gi_mean = gi_mean,
        gi_std = gi_std,
        case_data = case_data,
        tspan = tspan,
        epimethod = epimethod
    )

    @testset "config_parameters" begin
        @test config.gi_mean == gi_mean
        @test config.gi_std == gi_std
        @test config.igp == igp
        @test config.latent_model == latent_model
        @test config.case_data == case_data
        @test config.tspan == tspan
        @test config.epimethod == epimethod
    end
end

@testset "InferenceConfig: construct from all inference configurations" begin
    using Distributions, EpiAwarePipeline
    pipeline = RtwithoutRenewalPipeline()
    test_data = missing

    inference_configs = make_inference_configs(pipeline)
    @test [InferenceConfig(ic, test_data) isa InferenceConfig for ic in inference_configs] |>
          all
end

# define_epiprob(config::InferenceConfig)

# @testset "define_epiprob: creates `EpiProblem`" begin
#     using EpiAwarePipeline

#     inference_configs = make_inference_configs(pipeline)

# end
