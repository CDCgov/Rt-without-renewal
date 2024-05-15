@testset "default_gi_params: returns a dictionary with correct keys" begin
    using .AnalysisPipeline

    params = default_gi_params()
    @test params isa Dict
    @test haskey(params, "gi_means")
    @test haskey(params, "gi_stds")
end

@testset "default_Rt: returns an array" begin
    using .AnalysisPipeline

    Rt = default_Rt()
    @test Rt isa Array
end

@testset "default_tspan: returns an Tuple{Integer, Integer}" begin
    using .AnalysisPipeline

    tspan = default_tspan()
    @test tspan isa Tuple{Integer, Integer}
end

@testset "default_priors: generates a dict with correct keys and distributions" begin
    using .AnalysisPipeline, Distributions
    # Call the default_priors function
    priors_dict = default_latent_model_priors()

    # Check if the priors dictionary is constructed correctly
    @test haskey(priors_dict, "transformed_process_init_prior")
    @test haskey(priors_dict, "std_prior")
    @test haskey(priors_dict, "damp_param_prior")

    # Check if the values are all distributions
    @test valtype(priors_dict) <: Distribution
end

@testset "default_epiaware_models: generates a dict with correct keys and latent models" begin
    using .AnalysisPipeline, EpiAware

    models_dict = default_epiaware_models()

    @test haskey(models_dict, "wkly_ar")
    @test haskey(models_dict, "wkly_rw")
    @test haskey(models_dict, "wkly_diff_ar")
    @test valtype(models_dict) <: BroadcastLatentModel
end

@testset "default_inference_method: constructor and defaults" begin
    using .AnalysisPipeline, EpiAware, ADTypes, AbstractMCMC

    method = default_inference_method()
    @test length(method.pre_sampler_steps) == 1
    @test method.pre_sampler_steps[1] isa ManyPathfinder
    @test method.pre_sampler_steps[1].nruns == 4
    @test method.pre_sampler_steps[1].maxiters == 100
    @test method.sampler isa NUTSampler
    @test method.sampler.adtype == AutoForwardDiff()
    @test method.sampler.ndraws == 2000
    @test method.sampler.nchains == 2
    @test method.sampler.mcmc_parallel == MCMCSerial()
end

@testset "Test default_latent_models_names" begin
    using .AnalysisPipeline

    modelnames = default_latent_models_names()
    @test length(modelnames) == 3
    @test modelnames isa Dict
end

@testset "default_truthdata_configs" begin
    using .AnalysisPipeline
    @testset "default_truthdata_configs should return a dictionary" begin
        config_dicts = default_truthdata_configs()
        @test eltype(config_dicts) <: Dict
    end

    @testset "default_truthdata_configs should contain gi_mean and gi_std keys" begin
        config_dicts = default_truthdata_configs()
        @test all(config_dicts .|> config -> haskey(config, "gi_mean"))
        @test all(config_dicts .|> config -> haskey(config, "gi_std"))
    end
end

@testset "default inference configurations" begin
    @testset "default_inference_configs function" begin
        inference_configs = default_inference_configs()
        @test eltype(inference_configs) <: Dict
    end
end
