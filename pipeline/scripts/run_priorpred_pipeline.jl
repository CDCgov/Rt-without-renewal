# Local environment script to run the analysis pipeline
using Pkg
Pkg.activate(joinpath(@__DIR__(), ".."))
using Dagger

@assert !isempty(ARGS) "Test mode script requires the number of draws as an argument."
ndraws = parse(Int64, ARGS[1])

@info("""
      Running the prior predictive pipeline in test mode with $(ndraws) draws per model.
      --------------------------------------------
      """)

# Define the backend resources to use for the pipeline
# in this case we are using distributed local workers with loaded modules
using Distributed
pids = addprocs(; exeflags = ["--project=$(Base.active_project())"])

@everywhere using EpiAwarePipeline

# Create instances of the pipeline behaviour

pipelines = [
    SmoothOutbreakPipeline(ndraws = ndraws, nchains = 1, priorpredictive = true),
    MeasuresOutbreakPipeline(ndraws = ndraws, nchains = 1, priorpredictive = true),
    SmoothEndemicPipeline(ndraws = ndraws, nchains = 1, priorpredictive = true),
    RoughEndemicPipeline(ndraws = ndraws, nchains = 1, priorpredictive = true)
]

# Run the pipeline
do_pipeline(pipelines)

# Remove the workers
rmprocs(pids)
