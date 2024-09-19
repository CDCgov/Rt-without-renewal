using DrWatson, Test
quickactivate(@__DIR__(), "EpiAwarePipeline")
using EpiAwarePipeline, EpiAware

# Run tests
include("pipeline/test_pipelinetypes.jl");
# include("pipeline/test_pipelinefunctions.jl");
include("utils/test_calculate_processes.jl");
include("utils/test_simple_crps.jl");
include("constructors/test_constructors.jl");
include("simulate/test_TruthSimulationConfig.jl");
include("simulate/test_SimulationConfig.jl");
include("infer/test_InferenceConfig.jl");
include("infer/test_define_epiprob.jl");
include("forecast/test_forecast.jl");
include("scoring/test_score_parameters.jl");
