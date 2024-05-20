using Test
@testset "run prior predictive modelling for random scenario" begin
    using DrWatson, EpiAware
    quickactivate(@__DIR__(), "Analysis pipeline")
    include(srcdir("AnalysisPipeline.jl"))

    using AnalysisPipeline
    pipeline = RtwithoutRenewalPriorPipeline()

    tspan = (1, 28)
    inference_method = make_inference_method(pipeline)
    truth_data_config = make_truth_data_configs(pipeline)[1]
    inference_configs = make_inference_configs(pipeline)
    inference_config = rand(inference_configs)
    truthdata = Dict("y_t" => fill(100, 28), "truth_gi_mean" => 1.5)

    inference_results = generate_inference_results(
        truthdata, inference_config, pipeline; tspan, inference_method)
    @test inference_results["inference_results"] isa EpiAwareObservables
end
