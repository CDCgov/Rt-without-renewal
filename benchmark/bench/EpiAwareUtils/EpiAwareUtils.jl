module BenchEpiAwareUtils

using BenchmarkTools, EpiAware.EpiAwareUtils

suite = BenchmarkGroup()

include("censored_pmf.jl")

end
BenchEpiAwareUtils.suite
