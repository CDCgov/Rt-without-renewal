using Test

@testset "run inference and forecast for generated data" begin
    using DrWatson
    quickactivate(@__DIR__(), "EpiAwarePipeline")

    using EpiAwarePipeline, EpiAware, Plots, Statistics
    pipeline = EpiAwareExamplePipeline()
    prior = RtwithoutRenewalPriorPipeline()

    # Set up data generation on a random scenario
    lookahead = 60
    n_observation_steps = 28
    tspan_gen = (1, n_observation_steps + lookahead)
    tspan_inf = (1, n_observation_steps)
    inference_method = make_inference_method(pipeline)
    truth_data_config = make_truth_data_configs(pipeline)[1]
    inference_configs = make_inference_configs(pipeline)
    inference_config = rand(inference_configs)

    # Generate truth data and plot
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
    plot!((n_observation_steps+1):size(forecast_Z_t, 1),
        forecast_Z_t[(n_observation_steps + 1):end, :],
        label = "", color = :red, alpha = 0.05)
    vline!(plt_Zt, [n_observation_steps], label = "forecast start")

    savefig(plt_Zt,
        joinpath(@__DIR__(), "forecast_Z_t.png")
    )
end
