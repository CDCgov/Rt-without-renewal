"""
Module for defining latent models.
"""
module EpiLatentModels

using ..EpiAwareBase

using ..EpiAwareUtils: HalfNormal, prefix_submodel, accumulate_scan

using LogExpFunctions: softmax

using FillArrays: Fill

using Turing, Distributions, DocStringExtensions, LinearAlgebra

#Export models
export FixedIntercept, Intercept, IDD, RandomWalk, AR, MA, HierarchicalNormal

# Export tools for manipulating latent models
export CombineLatentModels, ConcatLatentModels, BroadcastLatentModel

# Export broadcast rules
export RepeatEach, RepeatBlock

# Export helper functions
export broadcast_rule, broadcast_dayofweek, broadcast_weekly, equal_dimensions

# Export tools for modifying latent models
export DiffLatentModel, TransformLatentModel, PrefixLatentModel, RecordExpectedLatent

include("docstrings.jl")
include("models/Intercept.jl")
include("models/IDD.jl")
include("models/RandomWalk.jl")
include("models/AR.jl")
include("models/MA.jl")
include("models/HierarchicalNormal.jl")
include("modifiers/DiffLatentModel.jl")
include("modifiers/TransformLatentModel.jl")
include("modifiers/PrefixLatentModel.jl")
include("modifiers/RecordExpectedLatent.jl")
include("manipulators/CombineLatentModels.jl")
include("manipulators/ConcatLatentModels.jl")
include("manipulators/broadcast/LatentModel.jl")
include("manipulators/broadcast/rules.jl")
include("manipulators/broadcast/helpers.jl")
include("utils.jl")

end
