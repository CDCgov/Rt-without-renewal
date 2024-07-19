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
do_pipeline(pipeline)
