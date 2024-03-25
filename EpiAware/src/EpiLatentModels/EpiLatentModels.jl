"""
Module for defining latent models.
"""
module EpiLatentModels

using Base: AbstractBroadcasted
using ..EpiAwareBase

using ..EpiAwareUtils: HalfNormal

using Turing, Distributions, DocStringExtensions

#Export models
export RandomWalk, AR, DiffLatentModel, BroadcastLatentModel

# Export broadcast rules
export RepeatEach, RepeatBlock

# Export helper functions
export dayofweek, weekly

include("docstrings.jl")
include("randomwalk.jl")
include("autoregressive.jl")
include("difflatentmodel.jl")
include("broadcast/latentmodel.jl")
include("broadcast/rules.jl")
include("broadcast/helpers.jl")
include("utils.jl")

end
