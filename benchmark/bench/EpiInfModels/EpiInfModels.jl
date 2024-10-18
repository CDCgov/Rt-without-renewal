module BenchEpiInfModels

using BenchmarkTools, TuringBenchmarking, EpiAware, Distributions, OrdinaryDiffEq
suite = BenchmarkGroup()

include("../../make_epiaware_suite.jl")
include("DirectInfections.jl")
include("ExpGrowthRate.jl")
include("InfectionODEProcess.jl")

end
BenchEpiInfModels.suite
