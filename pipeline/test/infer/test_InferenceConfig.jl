@testset "InferenceConfig: constructor function" begin
    using Distributions, EpiAwarePipeline, EpiAware

    struct TestLatentModel <: AbstractLatentModel
    end

    struct TestObsModel <: AbstractObservationModel
    end

    struct TestMethod <: AbstractEpiMethod
    end

    gi_mean = 3.0
    gi_std = 2.0
    igp = Renewal
    latent_model = TestLatentModel()
    observation_model = TestObsModel()
    epimethod = TestMethod()
    case_data = [10, 20, 30, 40, 50]
    I_t = [10, 20, 30, 40, 50] ./ 2
    I0 = 1.0
    tspan = (1, 5)
    lookahead = 10
    @testset "config_parameters back from constructor" begin
        config = InferenceConfig(igp, latent_model, observation_model;
            gi_mean = gi_mean,
            gi_std = gi_std,
            case_data = case_data,
            truth_I_t = I_t,
            truth_I0 = I0,
            tspan = tspan,
            epimethod = epimethod,
            log_I0_prior = Normal(log(100.0), 1e-5),
            lookahead = lookahead
        )

        @test config.gi_mean == gi_mean
        @test config.gi_std == gi_std
        @test config.igp == igp
        @test config.latent_model == latent_model
        @test config.observation_model == observation_model
        @test config.case_data == case_data
        @test config.tspan == tspan
        @test config.epimethod == epimethod
    end

    @testset "construct from config dictionary" begin
        pipeline = SmoothOutbreakPipeline()
        inference_configs = make_inference_configs(pipeline)
        @test [InferenceConfig(ic; case_data, truth_I_t = I_t,
                   truth_I0 = I0, tspan, epimethod) isa InferenceConfig
               for ic in inference_configs] |> all
    end
end
