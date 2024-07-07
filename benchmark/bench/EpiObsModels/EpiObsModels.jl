module BenchEpiObsModels

using BenchmarkTools, TuringBenchmarking, EpiAware
suite = BenchmarkGroup()

include("modifiers/ascertainment/Ascertainment.jl")
include("modifiers/ascertainment/helpers.jl")
include("modifiers/LatentDelay.jl")
include("modifiers/PrefixObservationModel.jl")

end
BenchEpiObsModels.suite
