using Test
@testset "run inference for random scenario with short toy data" begin
    using DrWatson
    quickactivate(@__DIR__(), "EpiAwarePipeline")

    using EpiAwarePipeline
    pipeline = RtwithoutRenewalPipeline()

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

##
using DrWatson
quickactivate(@__DIR__(), "EpiAwarePipeline")

using EpiAwarePipeline, EpiAware
pipeline = RtwithoutRenewalPipeline()
##
tspan = (1, 28)
inference_method = make_inference_method(pipeline)
truth_data_config = make_truth_data_configs(pipeline)[1]
inference_configs = make_inference_configs(pipeline)
inference_config = rand(inference_configs)
truthdata = Dict("y_t" => fill(100, 28), "truth_gi_mean" => 1.5)

inference_results = generate_inference_results(
    truthdata, inference_config, pipeline; tspan, inference_method)

res = inference_results["inference_results"]

##
sample_ary = get_param_array(res.samples)
##

chn = res.samples
lookahead = 21
forecast_config = InferenceConfig(inference_config; case_data = missing, tspan = (tspan[1], tspan[2] + lookahead), epimethod = make_inference_method(RtwithoutRenewalPriorPipeline()))
forecast_epiprob = define_epiprob(forecast_config)

forecast_results = apply_method(forecast_epiprob, forecast_config.epimethod, (y_t = missing,))
sample(chn, 1)
