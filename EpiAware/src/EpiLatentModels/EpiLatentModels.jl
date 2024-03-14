module EpiLatentModels

"""
Module for defining latent models.
"""

using ..EpiAwareBase

using Turing, Distributions, DocStringExtensions

export RandomWalk, default_rw_priors

include("randomwalk.jl")

end
