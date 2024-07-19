# Local environment script to run the analysis pipeline
using Pkg
Pkg.activate(joinpath(@__DIR__(), ".."))


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
@everywhere P = EpiAwareExamplePipeline(ndraws = 2_000, pipetype = MeasuresOutbreakPipeline)

truth_data_configs = make_truth_data_configs(P)
D = generate_truthdata(truth_data_configs[1], P; plot = false)
inference_configs = make_inference_configs(pipeline)
@everywhere inference_method = make_inference_method(pipeline)

results = pmap(inference_configs, fill(D, length(inference_configs))) do inference_config, truthdata
    generate_inference_results(
            truthdata, inference_config, P; inference_method)
end
