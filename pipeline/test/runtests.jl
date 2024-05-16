using DrWatson, Test
quickactivate(@__DIR__(), "Analysis pipeline")

# Load analysis module
include(srcdir("AnalysisPipeline.jl"));

#run tests
include("pipeline/test_pipelinetypes.jl");
include("constructors/default_returning_functions.jl");
include("constructors/test_constructors.jl");
include("simulate/test_TruthSimulationConfig.jl");
include("simulate/test_SimulationConfig.jl");
include("infer/test_InferenceConfig.jl");
