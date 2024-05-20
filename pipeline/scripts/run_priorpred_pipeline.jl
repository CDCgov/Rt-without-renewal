# Local environment script to run the analysis pipeline
using Pkg
Pkg.activate(joinpath(@__DIR__(), ".."))
using Dagger

@info("""
      Running the analysis pipeline.
      --------------------------------------------
      """)

# Define the backend resources to use for the pipeline
# in this case we are using distributed local workers with loaded modules
using Distributed
pids = addprocs()

@everywhere using Pkg
@everywhere Pkg.activate(joinpath(@__DIR__(), ".."))
@everywhere using AnalysisPipeline

# Create an instance of the pipeline behaviour
pipeline = RtwithoutRenewalPriorPipeline()

# Run the pipeline
do_pipeline(pipeline)

# Remove the workers
rmprocs(pids)
