module BenchEpiObsModels

using BenchmarkTools, TuringBenchmarking, EpiAware
suite = BenchmarkGroup()

include("modifiers/ascertainment/Ascertainment.jl")
end
BenchEpiObsModels.suite
