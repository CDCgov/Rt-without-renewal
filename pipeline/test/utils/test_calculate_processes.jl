using Test

@testset "calculate_processes" begin
    using EpiAware, EpiAwarePipeline
    using Random
    rng = MersenneTwister(1234)
    I0 = 10.0
    rt = randn(rng, 20)
    I_t = cumsum(rt) .+ log(I0) .|> exp
    pmf = [1.0]
    pipeline = EpiAwareExamplePipeline()

    data = EpiData(pmf, exp)

    result = calculate_processes(I_t, I0, data, pipeline)

    # Check if the log of infections is calculated correctly
    @testset "Log of infections" begin
        expected_log_I_t = log.(I_t)
        @test result.log_I_t ≈ expected_log_I_t
    end

    # Check if the exponential growth rate is calculated correctly
    @testset "Exponential growth rate" begin
        @test result.rt ≈ rt
    end

    # In this special case (pmf = [1.0]), the Rt = exp(rt)
    @testset "Instantaneous reproduction number" begin
        @test result.Rt ≈ exp.(rt)
    end
end
