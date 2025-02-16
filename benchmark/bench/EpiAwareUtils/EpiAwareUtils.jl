module BenchEpiAwareUtils

using BenchmarkTools, EpiAware.EpiAwareUtils
using ADTypes, Mooncake, Enzyme

Enzyme.API.runtimeActivity!(true)

suite = BenchmarkGroup()

include("censored_pmf.jl")

end
BenchEpiAwareUtils.suite
