"""
Module for defining latent models.
"""
module EpiLatentModels

using ..EpiAwareBase

using ..EpiAwareUtils

using LogExpFunctions: softmax

using FillArrays: Fill

using Turing, Distributions, DocStringExtensions, LinearAlgebra, SparseArrays,
      OrdinaryDiffEq

#Export models
export Null, FixedIntercept, Intercept, IID, RandomWalk, AR, MA, HierarchicalNormal

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

# Export combinations of models and modifiers
export define_arma, define_arima

include("docstrings.jl")
include("utils.jl")
include("models/Intercept.jl")
include("models/IID.jl")
include("models/RandomWalk.jl")
include("models/AR.jl")
include("models/MA.jl")
include("models/HierarchicalNormal.jl")
include("models/Null.jl")
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
include("combinations/define_arma.jl")
include("combinations/define_arima.jl")

end
