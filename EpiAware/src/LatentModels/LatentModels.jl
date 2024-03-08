module LatentModels

"""
Module for defining latent models.
"""

include("../EpiAwareBase/EpiAwareBase.jl")
using .EpiAwareBase

using Turing, Distributions, DocStringExtensions

export RandomWalk

include("randomwalk.jl")

end
