module BenchEpiInfModels

using BenchmarkTools, TuringBenchmarking, EpiAware, Distributions
using ADTypes, Mooncake, Enzyme

Enzyme.API.runtimeActivity!(true)

suite = BenchmarkGroup()

include("../../make_epiaware_suite.jl")
include("DirectInfections.jl")
include("ExpGrowthRate.jl")

end
BenchEpiInfModels.suite
