
@testset "timeseries_samples_into_quantiles tests" begin
    using EpiAwarePipeline
    X = [1 2 3; 4 5 6; 7 8 9]
    qs = [0.25, 0.5, 0.75]
    expected_output = [1.5 2.0 2.5
                       4.5 5.0 5.5
                       7.5 8.0 8.5]
    @test timeseries_samples_into_quantiles(X, qs) == expected_output
end

@testset "generate_quantiles_for_targets tests" begin
    output = Dict("inference_results" => Dict(
        "generated" => [1, 2, 3], "samples" => Dict(:init_incidence => [0.1, 0.2, 0.3])))
    D = EpiData()
    qs = [0.25, 0.5, 0.75]
    expected_output = [
        [0.1 0.2 0.3; 0.1 0.2 0.3; 0.1 0.2 0.3], [0.1 0.2 0.3; 0.1 0.2 0.3; 0.1 0.2 0.3],
        [0.1 0.2 0.3; 0.1 0.2 0.3; 0.1 0.2 0.3]]
    @test generate_quantiles_for_targets(output, D, qs) == expected_output
end
