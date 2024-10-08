@testset "Prior pred plotting" begin
    using CairoMakie
    #pick a random scenario
    pipetype = [SmoothOutbreakPipeline, MeasuresOutbreakPipeline,
        SmoothEndemicPipeline, RoughEndemicPipeline] |> rand
    P = pipetype(; testmode = true, nchains = 1, ndraws = 2000, priorpredictive = true)
    inference_config = make_inference_configs(P) |> rand
    inference_config["T"] = 21
    #Add missing data
    missingdata = Dict("y_t" => missing, "I_t" => fill(1.0, 100), "truth_I0" => 1.0,
        "truth_gi_mean" => inference_config["gi_mean"])
    results = generate_inference_results(missingdata, inference_config, P)

    fig = results["priorpredictive"]

    @test fig isa String #Figure object no longer returned
end
