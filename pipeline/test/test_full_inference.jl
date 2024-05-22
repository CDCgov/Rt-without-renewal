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

using EpiAwarePipeline, EpiAware, DynamicPPL
pipeline = RtwithoutRenewalPipeline()
prior = RtwithoutRenewalPriorPipeline()

##
tspan = (1, 28)
inference_method = make_inference_method(pipeline)
truth_data_config = make_truth_data_configs(pipeline)[1]
inference_configs = make_inference_configs(pipeline)
inference_config = rand(inference_configs)
_truthdata = Dict("y_t" => missing, "truth_gi_mean" => 1.5)

truthdata = generate_inference_results(
    _truthdata, inference_config, prior; tspan, inference_method = make_inference_method(prior)) |>
            d -> d["inference_results"] |>
                 d -> d.generated[1].generated_y_t

##
inference_results = generate_inference_results(
    Dict("y_t" => truthdata, "truth_gi_mean" => 1.5), inference_config, pipeline; tspan, inference_method)

res = inference_results["inference_results"]

##
chn = res.samples |> resetrange

_chn = Chains(randn(500, 3, 4),
    [Symbol("latent.ϵ_t[5]"), Symbol("latent.ϵ_t[6]"), Symbol("latent.ϵ_t[7]")] .|> Symbol)

new_chn = hcat(chn, _chn)
##

lookahead = 21
forecast_config = InferenceConfig(
    inference_config; case_data = missing, tspan = (tspan[1], tspan[2] + lookahead),
    epimethod = make_inference_method(RtwithoutRenewalPriorPipeline()))
forecast_epiprob = define_epiprob(forecast_config)
mdl = generate_epiaware(forecast_epiprob, (y_t = missing,))

##
fr_gens = generated_quantities(mdl, new_chn)
##
scatter(truthdata)
scatter!(fr_gens[9].generated_y_t, ms = 3)
