module EpiAwareBase

"""
Module for defining abstract epidemiological types.
"""

using DocStringExtensions

#Export models
export AbstractModel, AbstractEpiModel, AbstractLatentModel, AbstractObservationModel

#Export problems
export AbstractEpiProblem

#Export inference methods
export AbstractEpiMethod, AbstractEpiOptMethod, AbstractEpiSamplingMethod

#Export functions
export generate_latent, generate_latent_infs, generate_observations

include("docstrings.jl")
include("types.jl")
include("functions.jl")

end
