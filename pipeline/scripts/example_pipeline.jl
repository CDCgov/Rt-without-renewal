# Local environment script to run the analysis pipeline
using Pkg
Pkg.activate(joinpath(@__DIR__(), ".."))
using Dagger

@info("""
      Running the example pipeline.
      --------------------------------------------
      """)
##

using Distributed

pids = addprocs(; exeflags = ["--project=pipeline"])
# Add 4 processors from another machine
pids_remote = addprocs([("sam@192.168.0.248", 4)];
    dir = "/Users/sam/GitHub/CFA/Rt-without-renewal",
    exename = "/Users/sam/.juliaup/bin/julia",
    exeflags = ["--project=pipeline"])


@everywhere using EpiAwarePipeline

pipeline = EpiAwareExamplePipeline(ndraws = 1000, pipetype = MeasuresOutbreakPipeline)

list = make_inference_configs(pipeline)
l = make_truth_data_configs(pipeline)
do_truthdata(pipeline)

##
using JLD2, Plots, Distributions, EpiAware, DynamicPPL

D = JLD2.load(joinpath("pipeline", "data", "example_truth_data",
    "truth_data_I0=100.0_cluster_factor=0.05_gi_mean=2.0_gi_std=2.0.jld2"))
scatter(D["y_t"])
##
inf_method = make_inference_method(pipeline)
I = generate_inference_results(
    D, list[2], pipeline; inference_method = inf_method)
##
res = I["forecast_results"]
pre = I["inference_results"]

p = plot()
for gen in res.generated
    plot!(p, gen.I_t, lab = "", alpha = 0.05, c = :grey)
end
scatter!(p, D["I_t"], lab = "Truth data", c = :black, ylims = (0, 1.5 * maximum(skipmissing(D["I_t"]))))
vline!(p, [35], lab = "ref time")

##

p = plot()
for gen in res.generated
    plot!(p, exp.(gen.Z_t), lab = "", alpha = 0.05, c = :grey)
end
scatter!(p, D["truth_process"], lab = "Truth data", c = :black, ylims = (0, 2.))
vline!(p, [35], lab = "ref time")
##

p = plot()
for gen in res.generated
    plot!(p, gen.generated_y_t, lab = "", alpha = 0.05, c = :grey)
end
scatter!(p, D["y_t"], lab = "Truth data", c = :black, ylims = (0, 1.5 * maximum(skipmissing(D["y_t"]))))
vline!(p, [35], lab = "ref time")
