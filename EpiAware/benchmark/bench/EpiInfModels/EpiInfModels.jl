module BenchEpiInfModels

using BenchmarkTools, TuringBenchmarking, EpiAware, Distributions
suite = BenchmarkGroup()

include("../../make_epiaware_suite.jl")
include("DirectInfections.jl")
include("ExpGrowthRate.jl")

end
BenchEpiInfModels.suite
