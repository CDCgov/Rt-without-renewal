using Test

# @testset "run inference and forecast for generated data" begin
using DrWatson
quickactivate(@__DIR__(), "EpiAwarePipeline")

using EpiAwarePipeline, EpiAware, Plots, Statistics, Random
Random.seed!(1234)
pipeline = SmoothOutbreakPipeline(ndraws = 2000, testmode = true)

inference_method = make_inference_method(pipeline)
truth_data_config = make_truth_data_configs(pipeline)[1]
inference_config = make_inference_configs(pipeline)[1]
inference_config["T"] = 70
inference_config["lookback"] = 70

## Generate truth data and plot

truthdata = generate_truthdata(
    truth_data_config, pipeline::AbstractEpiAwarePipeline; plot = false)

##

plt_td = scatter(truthdata["y_t"] .+ 1, xlabel = "t", ylabel = "y_t",
    label = "truth data", yscale = :log10)
plot!(plt_td, truthdata["I_t"] .+ 1, label = "I_t")

##
tspan = make_tspan(
    pipeline; T = inference_config["T"], lookback = inference_config["T"])
config = InferenceConfig(
    inference_config; case_data = truthdata["y_t"], truth_I_t = truthdata["I_t"],
    truth_I0 = truthdata["truth_I0"], tspan, epimethod = inference_method)
epiprob = define_epiprob(config)
idxs = config.tspan[1]:config.tspan[2]

## Prior predictive checking
mdl = generate_epiaware(
    epiprob, (y_t = Vector{Union{Missing, Int64}}(undef, inference_config["T"]),))
X = mdl()
scatter(X.generated_y_t .+ 1, xlabel = "t", ylabel = "y_t",
    label = "prior predictive", yscale = :log10)

##

y_t = ismissing(config.case_data) ? missing :
      Vector{Union{Missing, Int64}}(config.case_data[idxs])

inference_results = apply_method(epiprob,
    config.epimethod,
    (y_t = y_t,);
)

##
gens = inference_results.generated
for gen in gens
    plot!(plt_td, tspan[1]:tspan[2], gen.I_t .+ 1, label = "", color = :grey, alpha = 0.05)
end
display(plt_td)
##
forecast_epiprob = define_forecast_epiprob(epiprob, 21)
forecast_mdl = generate_epiaware(forecast_epiprob, (y_t = missing,))
inference_chn = inference_results.samples
using Turing
pred_chn = mapreduce(chainscat, 1:size(inference_chn, 3)) do c
    mapreduce(vcat, 1:size(inference_chn, 1)) do i
        fwd_chn = predict(forecast_mdl, inference_chn[i, :, c]; include_all = true)
        setrange(fwd_chn, i:i)
    end
end
data = inference_results.data

forecast_quantities = generated_observables(forecast_mdl, data, pred_chn)
epidata = epiprob.epi_model.data
score_results = summarise_crps(config, inference_results, forecast_quantities, epidata)

generate_inference_results(
    truthdata, inference_config, pipeline;
    inference_method)

##
truth_sampling = generate_inference_results(
    Dict("y_t" => missing, "truth_gi_mean" => 1.5), inference_config,
    prior; tspan = tspan_gen, inference_method = make_inference_method(prior)) |>
                 d -> d["inference_results"]

#Choose first sample to represent truth data
truthdata = truth_sampling.generated[1].generated_y_t

plt = scatter(truthdata, xlabel = "t", ylabel = "y_t", label = "truth data")
vline!(plt, [n_observation_steps], label = "forecast start")

# Run inference
obs_truthdata = truthdata[tspan_inf[1]:tspan_inf[2]]
inference_results = generate_inference_results(
    Dict("y_t" => obs_truthdata, "truth_gi_mean" => 1.5),
    inference_config, pipeline; tspan = tspan_inf, inference_method)

@test inference_results["inference_results"] isa EpiAwareObservables

# Make 21-day forecast
forecast_quantities = generate_forecasts(inference_results, lookahead)
@test forecast_quantities isa EpiAwareObservables

# Make forecast spaghetti plot
forecast_y_t = mapreduce(hcat, forecast_quantities.generated) do gen
    gen.generated_y_t
end
forecast_qs = mapreduce(hcat, [0.025, 0.25, 0.5, 0.75, 0.975]) do q
    map(eachrow(forecast_y_t)) do row
        if any(ismissing, row)
            return missing
        else
            quantile(row, q)
        end
    end
end
plot!(plt, forecast_qs, label = "forecast quantiles",
    color = :grey, lw = [0.5 1.5 3 1.5 0.5])
plot!(plt, ylims = (-0.5, maximum(truthdata) * 1.25))
savefig(plt,
    joinpath(@__DIR__(), "forecast_y_t.png")
)

# Make forecast plot for Z_t
infer_Z_t = mapreduce(hcat, inference_results["inference_results"].generated) do gen
    gen.Z_t
end
forecast_Z_t = mapreduce(hcat, forecast_quantities.generated) do gen
    gen.Z_t
end
plt_Zt = plot(
    truth_sampling.generated[1].Z_t, lw = 3, color = :black, label = "truth Z_t")
plot!(plt_Zt, infer_Z_t, xlabel = "t", ylabel = "Z_t",
    label = "", color = :grey, alpha = 0.05)
plot!((n_observation_steps + 1):size(forecast_Z_t, 1),
    forecast_Z_t[(n_observation_steps + 1):end, :],
    label = "", color = :red, alpha = 0.05)
vline!(plt_Zt, [n_observation_steps], label = "forecast start")

savefig(plt_Zt,
    joinpath(@__DIR__(), "forecast_Z_t.png")
)
# end
