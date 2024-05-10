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
    priors_dict = default_priors()

    # Check if the priors dictionary is constructed correctly
    @test haskey(priors_dict, "transformed_process_init_prior")
    @test haskey(priors_dict, "std_prior")
    @test haskey(priors_dict, "damp_param_prior")

    # Check if the values are all distributions
    @test valtype(priors_dict) <: Distribution
end
