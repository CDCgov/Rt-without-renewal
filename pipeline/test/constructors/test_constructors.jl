@testset "make_gi_params: returns a dictionary with correct keys" begin
    using EpiAwarePipeline
    pipeline = RtwithoutRenewalTestPipeline()
    params = make_gi_params(pipeline)

    @test params isa Dict
    @test haskey(params, "gi_means")
    @test haskey(params, "gi_stds")
end

@testset "make_inf_generating_processes" begin
    using EpiAwarePipeline, EpiAware
    pipeline = RtwithoutRenewalTestPipeline()
    igps = make_inf_generating_processes(pipeline)
    @test igps == [DirectInfections, ExpGrowthRate, Renewal]
end

@testset "make_Rt: returns an array" begin
    using EpiAwarePipeline
    pipeline = RtwithoutRenewalTestPipeline()

    Rt = make_Rt(pipeline)
    @test Rt isa Array
end

@testset "default_tspan: returns an Tuple{Integer, Integer}" begin
    using EpiAwarePipeline
    pipeline = RtwithoutRenewalTestPipeline()

    tspan = make_tspan(pipeline)
    @test tspan isa Tuple{Integer, Integer}
end

@testset "make_latent_model_priors: generates a dict with correct keys and distributions" begin
    using EpiAwarePipeline, Distributions
    pipeline = RtwithoutRenewalTestPipeline()

    priors_dict = make_latent_model_priors(pipeline)

    # Check if the priors dictionary is constructed correctly
    @test haskey(priors_dict, "transformed_process_init_prior")
    @test haskey(priors_dict, "std_prior")
    @test haskey(priors_dict, "damp_param_prior")

    # Check if the values are all distributions
    @test valtype(priors_dict) <: Distribution
end

@testset "make_epiaware_name_model_pairs: generates a vector of Pairs with correct keys and latent models" begin
    using EpiAwarePipeline, EpiAware
    pipeline = RtwithoutRenewalTestPipeline()

    namemodel_vect = make_epiaware_name_model_pairs(pipeline)

    @test first.(namemodel_vect) == ["wkly_ar", "wkly_rw", "wkly_diff_ar"]
    @test all([model isa BroadcastLatentModel for model in last.(namemodel_vect)])
end

@testset "make_inference_method: constructor and defaults" begin
    using EpiAwarePipeline, EpiAware, ADTypes, AbstractMCMC
    pipeline = RtwithoutRenewalTestPipeline()

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
    pipeline = RtwithoutRenewalTestPipeline()
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
    pipeline = RtwithoutRenewalTestPipeline()

    inference_configs = make_inference_configs(pipeline)
    @test eltype(inference_configs) <: Dict
end
