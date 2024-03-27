"""
Module for defining abstract epidemiological types.
"""
module EpiAwareBase

using DocStringExtensions, DynamicPPL

#Export models
export AbstractModel, AbstractEpiModel, AbstractLatentModel, AbstractObservationModel

#Export problems
export AbstractEpiProblem, EpiAwareProblem

#Export inference methods
export AbstractEpiMethod, AbstractEpiOptMethod, AbstractEpiSamplingMethod, EpiMethod

# Export support types
export AbstractBroadcastRule

export generate_latent, generate_latent_infs, generate_observations, _apply_method

#Export support functions
export broadcast_rule, broadcast_n

include("docstrings.jl")
include("types.jl")
include("functions.jl")
include("generate_models.jl")
include("EpiAwareProblem.jl")

end
