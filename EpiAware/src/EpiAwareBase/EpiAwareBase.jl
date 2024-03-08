module EpiAwareBase

"""
Module for defining abstract epidemiological types.
"""

using Turing, DocStringExtensions

export AbstractModel, AbstractEpiModel, AbstractLatentModel,
       AbstractObservationModel, make_epi_aware, generate_latent,
       generate_latent_infs, generate_observations

include("types.jl")
include("functions.jl")
include("models.jl")

end
