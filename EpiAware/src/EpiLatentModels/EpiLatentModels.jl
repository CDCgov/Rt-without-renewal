"""
Module for defining latent models.
"""
module EpiLatentModels

using ..EpiAwareBase

using ..EpiAwareUtils: HalfNormal

using LogExpFunctions: softmax

using Turing, Distributions, DocStringExtensions, LinearAlgebra

#Export models
export FixedIntercept, Intercept, RandomWalk, AR, HierarchicalNormal

# Export tools for manipulating latent models
export CombineLatentModels, TransformLatentModel, DiffLatentModel, BroadcastLatentModel

# Export broadcast rules
export RepeatEach, RepeatBlock

# Export helper functions
export broadcast_dayofweek, broadcast_weekly

include("docstrings.jl")
include("Intercept.jl")
include("RandomWalk.jl")
include("AR.jl")
include("HierarchicalNormal.jl")
include("CombineLatentModels.jl")
include("TransformLatentModel.jl")
include("DiffLatentModel.jl")
include("broadcast/LatentModel.jl")
include("broadcast/rules.jl")
include("broadcast/helpers.jl")
include("utils.jl")

end
