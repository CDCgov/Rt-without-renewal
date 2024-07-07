module BenchEpiLatentModels

using BenchmarkTools, TuringBenchmarking, EpiAware, DynamicPPL
suite = BenchmarkGroup()

include("models/AR.jl")
include("models/RandomWalk.jl")
include("models/Intercept.jl")
include("models/FixedIntercept.jl")
include("models/HierarchicalNormal.jl")
include("modifiers/DiffLatentModel.jl")
include("modifiers/PrefixLatentModel.jl")
include("modifiers/TransformLatentModel.jl")
include("manipulators/CombineLatentModels.jl")
include("manipulators/ConcatLatentModels.jl")
include("manipulators/broadcast/LatentModel.jl")
include("manipulators/broadcast/helpers.jl")
end
BenchEpiLatentModels.suite
