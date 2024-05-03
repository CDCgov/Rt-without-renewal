using DrWatson, Test
@quickactivate "Analysis pipeline"

# Load analysis module
include(srcdir("AnalysisPipeline.jl"))

#run tests
include("test_SimulationConfig.jl");
include("test_TruthSimulationConfig.jl");
