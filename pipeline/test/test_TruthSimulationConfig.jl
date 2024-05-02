@testset "simulate_or_infer: simulate runs" begin
    using Distributions, .AnalysisPipeline, EpiAware
    # Define a mock TruthSimulationConfig object for testing
    config = TruthSimulationConfig(
        truth_process = fill(1.5, 10), generation_distribution = Gamma(2, 2))
    # Test the simulate_or_infer function
    @testset "simulate_or_infer" begin
        result = simulate_or_infer(config)

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
end
