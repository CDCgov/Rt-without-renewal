@testset "simulate runs" begin
    using Distributions, EpiAwarePipeline, EpiAware
    # Define a mock TruthSimulationConfig object for testing
    config = TruthSimulationConfig(
        truth_process = fill(1.5, 10), gi_mean = 2.0, gi_std = 2.0)
    # Test the simulate function
    result = simulate(config)

    @test haskey(result, "I_t")
    @test haskey(result, "y_t")
    @test haskey(result, "cluster_factor")
    @test haskey(result, "truth_process")
    @test haskey(result, "truth_gi_mean")
    @test haskey(result, "truth_gi_std")

    # The latent infections should be increasing with Rt > 1 for all time steps
    growth_up = diff(log.(result["I_t"])) .> 0
    @test all(growth_up)
end

@testset "generate_truthdata" begin
    using EpiAwarePipeline
    pipeline = RtwithoutRenewalTestPipeline()
    truth_data_config = Dict("gi_mean" => 0.5, "gi_std" => 0.1)
    truthdata = generate_truthdata(truth_data_config, pipeline)

    @test haskey(truthdata, "I_t")
    @test haskey(truthdata, "y_t")
    @test haskey(truthdata, "cluster_factor")
    @test haskey(truthdata, "truth_process")
    @test haskey(truthdata, "truth_gi_mean")
    @test haskey(truthdata, "truth_gi_std")
end
