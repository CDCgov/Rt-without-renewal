module EpiAwareBase

"""
Module for defining abstract epidemiological types.
"""

using DocStringExtensions

export AbstractModel, AbstractEpiModel, AbstractLatentModel,
       AbstractObservationModel, AbstractEpiAwareProblem, generate_latent,
       generate_latent_infs, generate_observations

include("docstrings.jl")
include("types.jl")
include("functions.jl")

end
