
# Test the InferenceConfig struct constructor
@testset "InferenceConfig" begin
    using Distributions, .AnalysisPipeline, EpiAware

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

@testset "simulate_or_infer: Inference runs" begin
    using Distributions, .AnalysisPipeline, EpiAware, ADTypes, AbstractMCMC

    @info "Running inference test on fake data."

    include(srcdir("AnalysisPipeline.jl"))
    include(scriptsdir("common_param_values.jl"))
    include(scriptsdir("common_scenarios.jl"))

    # Inference method
    num_threads = min(10, Threads.nthreads())

    inference_method = EpiMethod(
        pre_sampler_steps = [ManyPathfinder(nruns = 4, maxiters = 100)],
        sampler = NUTSampler(adtype = AutoForwardDiff(),
            ndraws = 2000,
            nchains = num_threads,
            mcmc_parallel = MCMCThreads())
    )

    # Create the InferenceConfig object on a randomly selected simulation configuration
    # With fake constant case data
    idx = rand(1:length(sim_configs))

    config = sim_configs[idx] |>
        d -> InferenceConfig(d[:igp], d[:latent_model];
            gi_mean = d[:gi_mean],
            gi_std = d[:gi_std],
            case_data = fill(100, 100), # Fake constant case data
            tspan = (1,25),
            epimethod = inference_method
        )

    # Call the simulate_or_infer function
    inference_results = simulate_or_infer(config)

    # Check if the results match the expected results
    @test inference_results isa EpiAwareObservables
end
