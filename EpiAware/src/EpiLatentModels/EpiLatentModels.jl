"""
Module for defining latent models.
"""
module EpiLatentModels

using ..EpiAwareBase

using Turing, Distributions, DocStringExtensions

#Export models
export RandomWalk, AR, DiffLatentModel

include("docstrings.jl")
include("randomwalk.jl")
include("autoregressive.jl")
include("difflatentmodel.jl")
include("utils.jl")

end
