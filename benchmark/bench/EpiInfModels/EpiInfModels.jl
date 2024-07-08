module BenchEpiInfModels

using BenchmarkTools, TuringBenchmarking, EpiAware, Distributions
suite = BenchmarkGroup()

include("DirectInfections.jl")
include("ExpGrowthRate.jl")

end
BenchEpiInfModels.suite
