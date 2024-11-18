"""
Module for defining latent models.
"""
module EpiLatentModels

using ..EpiAwareBase

using ..EpiAwareUtils: HalfNormal, prefix_submodel, accumulate_scan

using LogExpFunctions: softmax

using FillArrays: Fill

using Turing, Distributions, DocStringExtensions, LinearAlgebra, SparseArrays,
      OrdinaryDiffEq

#Export models
export FixedIntercept, Intercept, RandomWalk, AR, HierarchicalNormal

#Export ODE definitions
export SIRParams, SEIRParams

# Export tools for manipulating latent models
export CombineLatentModels, ConcatLatentModels, BroadcastLatentModel

# Export broadcast rules
export RepeatEach, RepeatBlock

# Export helper functions
export broadcast_rule, broadcast_dayofweek, broadcast_weekly, equal_dimensions

# Export tools for modifying latent models
export DiffLatentModel, TransformLatentModel, PrefixLatentModel, RecordExpectedLatent

include("docstrings.jl")
include("utils.jl")
include("models/Intercept.jl")
include("models/RandomWalk.jl")
include("models/AR.jl")
include("models/HierarchicalNormal.jl")
include("odemodels/SIRParams.jl")
include("odemodels/SEIRParams.jl")
include("modifiers/DiffLatentModel.jl")
include("modifiers/TransformLatentModel.jl")
include("modifiers/PrefixLatentModel.jl")
include("modifiers/RecordExpectedLatent.jl")
include("manipulators/CombineLatentModels.jl")
include("manipulators/ConcatLatentModels.jl")
include("manipulators/broadcast/LatentModel.jl")
include("manipulators/broadcast/rules.jl")
include("manipulators/broadcast/helpers.jl")

end
