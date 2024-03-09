module LatentModels

"""
Module for defining latent models.
"""

include("../EpiAwareBase/EpiAwareBase.jl")
import .EpiAwareBase: AbstractLatentModel, generate_latent

using Turing, Distributions, DocStringExtensions

export RandomWalk, generate_latent

include("randomwalk.jl")

end
