module BenchEpiObsModels

using BenchmarkTools, TuringBenchmarking, EpiAware, DynamicPPL
using ADTypes, Mooncake, Enzyme

Enzyme.API.runtimeActivity!(true)

suite = BenchmarkGroup()

include("../../make_epiaware_suite.jl")
include("modifiers/ascertainment/Ascertainment.jl")
include("modifiers/ascertainment/helpers.jl")
include("modifiers/LatentDelay.jl")
include("modifiers/PrefixObservationModel.jl")
include("modifiers/RecordExpectedObs.jl")
include("modifiers/TransformObservationModel.jl")
include("ObservationErrorModels/methods.jl")
include("ObservationErrorModels/NegativeBinomialError.jl")
include("ObservationErrorModels/PoissonError.jl")
include("StackObservationModels.jl")

end
BenchEpiObsModels.suite
