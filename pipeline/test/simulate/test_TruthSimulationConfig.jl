@testset "simulate runs" begin
    using Distributions, LogExpFunctions
    # Define a mock TruthSimulationConfig object for testing
    logit_daily_ascertainment = [zeros(5); -0.5 * ones(2)]

    config = TruthSimulationConfig(
        truth_process = fill(1.5, 30), gi_mean = 2.0, gi_std = 2.0, logit_daily_ascertainment = logit_daily_ascertainment,
        cluster_factor = 0.1, I0 = 100.0)
    # Test the simulate function
    result = simulate(config)

    @test haskey(result, "I_t")
    @test haskey(result, "y_t")
    @test haskey(result, "truth_cluster_factor")
    @test haskey(result, "truth_process")
    @test haskey(result, "truth_gi_mean")
    @test haskey(result, "truth_gi_std")
    @test haskey(result, "truth_daily_ascertainment")
    @test haskey(result, "truth_I0")

    @test result["truth_daily_ascertainment"] ≈ 7 * softmax(logit_daily_ascertainment)

    # The latent infections should be increasing with Rt > 1 for all time steps
    growth_up = diff(log.(result["I_t"])) .> 0
    @test all(growth_up)
end

@testset "generate_truthdata" begin
    pipeline = EpiAwareExamplePipeline()
    truth_data_config = Dict("gi_mean" => 2.5, "gi_std" => 1.5)
    truthdata = generate_truthdata(truth_data_config, pipeline; plot = false)

    @test haskey(truthdata, "I_t")
    @test haskey(truthdata, "y_t")
    @test haskey(truthdata, "truth_cluster_factor")
    @test haskey(truthdata, "truth_process")
    @test haskey(truthdata, "truth_gi_mean")
    @test haskey(truthdata, "truth_gi_std")
    @test haskey(truthdata, "truth_daily_ascertainment")
    @test haskey(truthdata, "truth_I0")

    @test truthdata["y_t"] isa Vector{Union{Missing, T}} where {T <: Real}
end
