using DrWatson, Test
quickactivate(@__DIR__(), "EpiAwarePipeline")
using EpiAwarePipeline, EpiAware

# Run tests
include("pipeline/test_pipelinetypes.jl");
# include("pipeline/test_pipelinefunctions.jl");
include("utils/test_utils.jl");
include("constructors/test_constructors.jl");
include("simulate/test_simulate.jl");
include("infer/test_infer.jl");
include("forecast/test_forecast.jl");
include("scoring/test_score_parameters.jl");
include("plotting/plotting_tests.jl");
