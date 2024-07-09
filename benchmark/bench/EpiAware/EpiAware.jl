module BenchEpiAware

using BenchmarkTools, TuringBenchmarking, EpiAware
suite = BenchmarkGroup()

include("single-timeseries.jl")

end
BenchEpiAware.suite
