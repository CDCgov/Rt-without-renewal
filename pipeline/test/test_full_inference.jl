using Test
@testset "run inference for random scenario with short toy data" begin
    using DrWatson, EpiAware
    quickactivate(@__DIR__(), "Analysis pipeline")
    include(srcdir("AnalysisPipeline.jl"))

    using .AnalysisPipeline

    default_gi_param_dict = default_gi_params()
    true_Rt = default_Rt()
    latent_models_dict = default_epiaware_models()
    latent_models_names = Dict(value => key for (key, value) in latent_models_dict)
    tspan = (1, 28)
    inference_method = default_inference_method()

    truth_data_config = make_truth_data_configs(
        gi_means = default_gi_param_dict["gi_means"],
        gi_stds = default_gi_param_dict["gi_stds"])[1]
    inference_configs = make_inference_configs(
        latent_models = collect(values(latent_models_dict)),
        gi_means = default_gi_param_dict["gi_means"],
        gi_stds = default_gi_param_dict["gi_stds"])
    inference_config = rand(inference_configs)
    truthdata = Dict("y_t" => fill(100, 28))

    inference_results, inferencefile = generate_inference_results(
        truthdata, inference_config; tspan, inference_method,
        truth_data_config, latent_models_names)
    @test inference_results["inference_results"] isa EpiAwareObservables
end
