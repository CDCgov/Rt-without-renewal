using EpiAwarePipeline, EpiAware, Test
using Random
Random.seed!(123)
# Run tests
include("utils/test_utils.jl");
include("constructors/test_constructors.jl");
include("simulate/test_simulate.jl");
include("infer/test_infer.jl");
include("forecast/test_forecast.jl");
# include("scoring/test_score_parameters.jl");
# include("plotting/plotting_tests.jl");
include("pipeline/test_pipeline.jl");
