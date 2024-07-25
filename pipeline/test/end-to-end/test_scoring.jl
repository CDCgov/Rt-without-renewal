using DrWatson, Test
quickactivate(@__DIR__(), "EpiAwarePipeline")

@testset "run inference for random scenario and do scoring" begin
    using EpiAwarePipeline, EpiAware, Plots, Statistics
    pipeline = SmoothEndemicPipeline(ndraws = 200, nchains = 1, prefix = "test_score")

    truth_data_config = make_truth_data_configs(pipeline)[1]
    truthdata = generate_truthdata(truth_data_config, pipeline)

    ## Set up data generation on a random scenario with reference time in the middle
    inference_method = make_inference_method(pipeline)
    inference_config = make_inference_configs(pipeline) |>
                       cfgs -> filter(cfg -> cfg["T"] == 35, cfgs) |> rand

    ## Run inference, forecasting and scoring

    inference_results = generate_inference_results(
        truthdata, inference_config, pipeline; inference_method,
        datadir_name = "example_epiaware_observables")

    ## plot scores

    score_results = inference_results["score_results"]
    targets = filter(ky -> ky != "ts", keys(score_results))
    ts = score_results["ts"]
    plt_scores = plot(;
        xlabel = "Time", ylabel = "CRPS", title = "CRPS Scores (relative to max)")
    for target in targets
        scores = score_results[target]
        plot!(plt_scores, ts, scores ./ maximum(scores), label = target)
    end
    plot!(plt_scores, legend = :topleft)
    display(plt_scores)
    savefig(plt_scores,
        joinpath(@__DIR__(), "crps.png")
    )
    @test true
end
