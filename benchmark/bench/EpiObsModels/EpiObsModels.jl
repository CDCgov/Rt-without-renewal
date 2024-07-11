module BenchEpiObsModels

using BenchmarkTools, TuringBenchmarking, EpiAware, DynamicPPL
suite = BenchmarkGroup()

include("modifiers/ascertainment/Ascertainment.jl")
include("modifiers/ascertainment/helpers.jl")
include("modifiers/LatentDelay.jl")
include("modifiers/PrefixObservationModel.jl")
include("ObservationErrorModels/methods.jl")
include("ObservationErrorModels/NegativeBinomialError.jl")
include("ObservationErrorModels/PoissonError.jl")
include("StackObservationModels.jl")

end
BenchEpiObsModels.suite
