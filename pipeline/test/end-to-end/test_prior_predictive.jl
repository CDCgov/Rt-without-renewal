using Test, DrWatson
quickactivate(@__DIR__(), "EpiAwarePipeline")

using EpiAwarePipeline, EpiAware, Plots, Turing
pipetype = [SmoothOutbreakPipeline, MeasuresOutbreakPipeline,
    SmoothEndemicPipeline, RoughEndemicPipeline] |> rand

P = pipetype(; testmode = true, nchains = 1, ndraws = 2000, priorpredictive = true)

##

inference_method = make_inference_method(P)
inference_config = make_inference_configs(P) |> first
