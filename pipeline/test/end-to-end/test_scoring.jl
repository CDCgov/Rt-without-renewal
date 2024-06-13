using DrWatson
quickactivate(@__DIR__(), "EpiAwarePipeline")

using EpiAwarePipeline, EpiAware, Plots, Statistics
pipeline = EpiAwareExamplePipeline()
prior = RtwithoutRenewalPriorPipeline()

## Set up data generation on a random scenario

missing_padding = 14
lookahead = 21
n_observation_steps = 35
tspan_gen = (1, n_observation_steps + lookahead + missing_padding)
tspan_inf = (1, n_observation_steps + missing_padding)
inference_method = make_inference_method(pipeline)
truth_data_config = make_truth_data_configs(pipeline)[1]
inference_configs = make_inference_configs(pipeline)
inference_config = rand(inference_configs)

## Generate truth data and plot
truth_sampling = generate_inference_results(inference_config, prior; tspan = tspan_gen)
truthdata = truth_sampling["inference_results"].generated.generated_y_t
##
plt = scatter(truthdata, xlabel = "t", ylabel = "y_t", label = "truth data")
vline!(plt, [n_observation_steps + missing_padding + 0.5], label = "forecast start")


## Run inference
obs_truthdata = truthdata[tspan_inf[1]:tspan_inf[2]]

inference_results = generate_inference_results(
        Dict("y_t" => obs_truthdata, "truth_gi_mean" => inference_config["gi_mean"]),
        inference_config, pipeline; tspan = tspan_inf, inference_method)

## Make 21-day forecast

forecast_quantities = generate_forecasts(inference_results, lookahead)
forecast_y_t = mapreduce(hcat, forecast_quantities.generated) do gen
    gen.generated_y_t
end
forecast_qs = mapreduce(hcat, [0.025, 0.25, 0.5, 0.75, 0.975]) do q
    map(eachrow(forecast_y_t)) do row
        if any(ismissing, row)
            missing
        else
            quantile(row, q)
        end
    end
end
plt = scatter(truthdata, xlabel = "t", ylabel = "y_t", label = "truth data")
vline!(plt, [n_observation_steps + missing_padding + 0.5], label = "forecast start")
plot!(plt, forecast_qs, label = "forecast quantiles",
    color = :grey, lw = [0.5 1.5 3 1.5 0.5])
plot!(plt, ylims = (-0.5, maximum(truthdata) * 1.25))
plot!(plt, title = "Forecast of y_t", ylims = (-0.5, maximum(skipmissing(truthdata)) * 1.25))
savefig(plt,
    joinpath(@__DIR__(), "forecast_y_t.png")
)
display(plt)

## Make forecast plot for Z_t
infer_Z_t = mapreduce(hcat, inference_results["inference_results"].generated) do gen
    gen.Z_t
end
forecast_Z_t = mapreduce(hcat, forecast_quantities.generated) do gen
    gen.Z_t
end
plt_Zt = plot(
    truth_sampling["inference_results"].generated.Z_t, lw = 3, color = :black, label = "truth Z_t")
plot!(plt_Zt, infer_Z_t, xlabel = "t", ylabel = "Z_t",
    label = "", color = :grey, alpha = 0.05)
plot!((n_observation_steps + 1):size(forecast_Z_t, 1),
    forecast_Z_t[(n_observation_steps + 1):end, :],
    label = "", color = :red, alpha = 0.05)
vline!(plt_Zt, [n_observation_steps], label = "forecast start")

savefig(plt_Zt,
    joinpath(@__DIR__(), "forecast_Z_t.png")
)
