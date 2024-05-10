@testset "run inference for random scenario with short toy data" begin
    using DrWatson, .AnalysisPipeline, EpiAware
    @quickactivate "Analysis pipeline"

    include(srcdir("AnalysisPipeline.jl"))

    default_gi_param_dict = default_gi_params()
    true_Rt = default_Rt()
    latent_models_dict = default_epiaware_models()
    latent_models_names = Dict(value => key for (key, value) in latent_models_dict)
    tspan = default_tspan()
    inference_method = default_inference_method()

    inference_configs = make_inference_configs(
        latent_models = collect(values(latent_models_dict)),
        gi_means = default_gi_param_dict["gi_means"],
        gi_stds = default_gi_param_dict["gi_stds"])

    #randomly select an inference configuration
    inference_config = rand(inference_configs)

    config = InferenceConfig(inference_config["igp"], inference_config["latent_model"];
        gi_mean = inference_config["gi_mean"],
        gi_std = inference_config["gi_std"],
        case_data = fill(100, 28),
        tspan = (1, 28),
        epimethod = inference_method
    )

    inference_results, inferencefile = produce_or_load(
        simulate_or_infer, config, datadir("epiaware_observables"); prefix = "test")

    @test inference_results["inference_results"] isa EpiAwareObservables
end
