using DrWatson, Test
quickactivate(@__DIR__(), "Analysis pipeline")

# Load analysis module
include(srcdir("AnalysisPipeline.jl"));

#run tests
include("default_returning_functions.jl");
include("test_make_configs.jl");
include("test_SimulationConfig.jl");
include("test_TruthSimulationConfig.jl");
include("test_InferenceConfig.jl");
