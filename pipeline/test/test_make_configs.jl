@testset "make_truth_data_configs: I/O" begin
    using .AnalysisPipeline, DrWatson

    gi_means = [1.0, 2.0, 3.0]
    gi_stds = [0.5, 0.8, 1.2]
    expected_output = Dict("gi_mean" => gi_means, "gi_std" => gi_stds)
    @test make_truth_data_configs(gi_means = gi_means, gi_stds = gi_stds) ==
          dict_list(expected_output)
end
