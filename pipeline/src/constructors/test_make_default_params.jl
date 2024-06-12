using Test

@testset "make_default_params" begin
    # Mock pipeline object
    struct MockPipeline <: AbstractEpiAwarePipeline end
    pipeline = MockPipeline()

    # Expected default parameters
    expected_params = Dict(
        "Rt" => 1.0,
        "logit_daily_ascertainment" => [zeros(5); -0.5 * ones(2)],
        "cluster_factor" => 0.1,
        "I0" => 100.0
    )

    # Test the make_default_params function
    @test make_default_params(pipeline) == expected_params
end
