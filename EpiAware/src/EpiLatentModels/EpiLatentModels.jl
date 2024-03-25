"""
Module for defining latent models.
"""
module EpiLatentModels

using ..EpiAwareBase

using ..EpiAwareUtils: HalfNormal

using Turing, Distributions, DocStringExtensions

#Export models
export RandomWalk, AR, DiffLatentModel, BroadcastLatentModel, DayOfWeek, Weekly

include("docstrings.jl")
include("randomwalk.jl")
include("autoregressive.jl")
include("difflatentmodel.jl")
include("broadcastlatentmodel.jl")
include("broadcasthelpers.jl")
include("utils.jl")

end
