module EpiLatentModels

"""
Module for defining latent models.
"""

include("../EpiAwareBase/EpiAwareBase.jl")
import .EpiAwareBase: AbstractLatentModel, generate_latent

using Turing, Distributions, DocStringExtensions

export RandomWalk, generate_latent, default_rw_priors

include("randomwalk.jl")

end
