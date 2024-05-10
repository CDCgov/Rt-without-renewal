@testset "make_truth_data_configs: I/O" begin
    using .AnalysisPipeline, DrWatson

    gi_means = [1.0, 2.0, 3.0]
    gi_stds = [0.5, 0.8, 1.2]
    expected_output = Dict("gi_mean" => gi_means, "gi_std" => gi_stds)
    @test make_truth_data_configs(gi_means = gi_means, gi_stds = gi_stds) ==
          dict_list(expected_output)
end

@testset "make_inference_configs: I/O" begin
    using .AnalysisPipeline, DrWatson, EpiAware
    struct TestLatentModel <: AbstractLatentModel end

    latent_models = [TestLatentModel()]
    gi_means = [2.0, 3.0, 4.0]
    gi_stds = [1.0, 2.0, 3.0]
    igps = [DirectInfections, Renewal]
    expected_result = Dict(
        "igp" => [DirectInfections, Renewal], "latent_model" => latent_models,
        "gi_mean" => gi_means, "gi_std" => gi_stds) |> dict_list
    @test make_inference_configs(latent_models = latent_models, gi_means = gi_means,
        gi_stds = gi_stds, igps = igps) == expected_result
end
