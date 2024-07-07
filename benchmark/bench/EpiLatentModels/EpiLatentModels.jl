module BenchEpiLatentModels

using BenchmarkTools, TuringBenchmarking, EpiAware
suite = BenchmarkGroup()

include("models/AR.jl")
end
BenchEpiLatentModels.suite
