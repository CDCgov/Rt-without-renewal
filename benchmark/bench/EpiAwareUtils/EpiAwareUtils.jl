module BenchEpiAwareUtils

using BenchmarkTools, EpiAware

suite = BenchmarkGroup()

include("censored_pmf.jl")

end
BenchEpiAwareUtils.suite
