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
addprocs()

@everywhere include("../src/AnalysisPipeline.jl")
@everywhere using .AnalysisPipeline

# Create an instance of the pipeline behaviour
pipeline = AnalysisPipeline.EpiAwarePipeline()

# Run the pipeline
make_pipeline(pipeline)