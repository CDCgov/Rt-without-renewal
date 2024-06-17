@testset "make_gi_params: returns a dictionary with correct keys" begin
    using EpiAwarePipeline
    pipeline = EpiAwareExamplePipeline()
    params = make_gi_params(pipeline)

    @test params isa Dict
    @test haskey(params, "gi_means")
    @test haskey(params, "gi_stds")
end

@testset "make_inf_generating_processes" begin
    using EpiAwarePipeline, EpiAware
    pipeline = EpiAwareExamplePipeline()
    igps = make_inf_generating_processes(pipeline)
    @test igps == [DirectInfections, ExpGrowthRate, Renewal]
end

@testset "make_Rt: returns an array" begin
    using EpiAwarePipeline
    pipeline = EpiAwareExamplePipeline()

    Rt = make_Rt(pipeline)
    @test Rt isa Array
end

@testset "default_tspan: returns an Tuple{Integer, Integer}" begin
    using EpiAwarePipeline
    pipeline = EpiAwareExamplePipeline()

    tspan = make_tspan(pipeline)
    @test tspan isa Tuple{Integer, Integer}
end

@testset "make_model_priors: generates a dict with correct keys and distributions" begin
    using EpiAwarePipeline, Distributions
    pipeline = EpiAwareExamplePipeline()

    priors_dict = make_model_priors(pipeline)

    # Check if the priors dictionary is constructed correctly
    @test haskey(priors_dict, "transformed_process_init_prior")
    @test haskey(priors_dict, "std_prior")
    @test haskey(priors_dict, "damp_param_prior")

    # Check if the values are all distributions
    @test valtype(priors_dict) <: Distribution
end

@testset "make_epiaware_name_latentmodel_pairs: generates a vector of Pairs with correct keys and latent models" begin
    using EpiAwarePipeline, EpiAware
    pipeline = EpiAwareExamplePipeline()

    namemodel_vect = make_epiaware_name_latentmodel_pairs(pipeline)

    @test first.(namemodel_vect) == ["wkly_ar", "wkly_rw", "wkly_diff_ar"]
    @test all([model isa BroadcastLatentModel for model in last.(namemodel_vect)])
end

@testset "make_inference_method: constructor and defaults" begin
    using EpiAwarePipeline, EpiAware, ADTypes, AbstractMCMC
    pipeline = EpiAwareExamplePipeline()

    method = make_inference_method(pipeline)

    @test length(method.pre_sampler_steps) == 1
    @test method.pre_sampler_steps[1] isa ManyPathfinder
    @test method.pre_sampler_steps[1].nruns == 4
    @test method.pre_sampler_steps[1].maxiters == 100
    @test method.sampler isa NUTSampler
    @test method.sampler.adtype == AutoForwardDiff()
    @test method.sampler.ndraws == 2000
    @test method.sampler.nchains == 4
    @test method.sampler.mcmc_parallel == MCMCThreads()
end

@testset "make_inference_method: for prior predictive checking" begin
    using EpiAwarePipeline, EpiAware, ADTypes, AbstractMCMC
    pipeline = RtwithoutRenewalPriorPipeline()

    method = make_inference_method(pipeline)

    @test length(method.pre_sampler_steps) == 0
    @test method.sampler isa DirectSample
end

@testset "make_truth_data_configs" begin
    using EpiAwarePipeline
    pipeline = EpiAwareExamplePipeline()
    @testset "make_truth_data_configs should return a dictionary" begin
        config_dicts = make_truth_data_configs(pipeline)
        @test eltype(config_dicts) <: Dict
    end

    @testset "make_truth_data_configs should contain gi_mean and gi_std keys" begin
        config_dicts = make_truth_data_configs(pipeline)
        @test all(config_dicts .|> config -> haskey(config, "gi_mean"))
        @test all(config_dicts .|> config -> haskey(config, "gi_std"))
    end
end

@testset "default inference configurations" begin
    using EpiAwarePipeline
    pipeline = EpiAwareExamplePipeline()

    inference_configs = make_inference_configs(pipeline)
    @test eltype(inference_configs) <: Dict
end

@testset "make_default_params" begin
    using EpiAwarePipeline
    pipeline = RtwithoutRenewalPipeline()

    # Expected default parameters
    expected_params = Dict(
        "Rt" => make_Rt(pipeline),
        "logit_daily_ascertainment" => [zeros(5); -0.5 * ones(2)],
        "cluster_factor" => 0.05,
        "I0" => 100.0,
        "α_delay" => 4.0,
        "θ_delay" => 5.0 / 4.0
    )

    # Test the make_default_params function
    @test make_default_params(pipeline) == expected_params
end

@testset "make_delay_distribution" begin
    pipeline = RtwithoutRenewalPipeline()
    delay_distribution = make_delay_distribution(pipeline)
    @test delay_distribution isa Distribution
    @test delay_distribution isa Gamma
    @test delay_distribution.α == 4.0
    @test delay_distribution.θ == 5.0 / 4.0
end

@testset "make_observation_model" begin
    using EpiAware
    # Mock pipeline object
    pipeline = RtwithoutRenewalPipeline()
    default_params = make_default_params(pipeline)
    obs = make_observation_model(pipeline)

    # Test case 1: Check if the returned object is of type LatentDelay
    @testset "Returned object type" begin
        @test obs isa LatentDelay
    end

    # Test case 2: Check if the default parameters are correctly passed to ascertainment_dayofweek
    @testset "Default parameters" begin
        @test obs.model.model.cluster_factor_prior ==
              HalfNormal(default_params["cluster_factor"])
    end
end
