"""
Module for defining abstract epidemiological types.
"""
module EpiAwareBase

using DocStringExtensions

#Export models
export AbstractModel, AbstractEpiModel, AbstractLatentModel, AbstractObservationModel

#Export problems
export AbstractEpiProblem

#Export inference methods
export AbstractEpiMethod, AbstractEpiOptMethod, AbstractEpiSamplingMethod

# Export support types
export AbstractBroadcastRule

#Export generating functions
export generate_latent, generate_latent_infs, generate_observations

#Export support functions
export broadcast_rule, broadcast_n

include("docstrings.jl")
include("types.jl")
include("functions.jl")
include("generate_models.jl")

end
