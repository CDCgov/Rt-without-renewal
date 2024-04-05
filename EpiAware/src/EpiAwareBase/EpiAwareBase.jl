"""
Module for defining abstract epidemiological types.
"""
module EpiAwareBase

using DocStringExtensions

### Abstract types ###

#Export models
export AbstractModel, AbstractEpiModel, AbstractLatentModel, AbstractObservationModel

# Export Turing-based models
export AbstractTuringEpiModel, AbstractTuringLatentModel, AbstractTuringObservationModel

# Export support types
export AbstractBroadcastRule

#Export problems
export AbstractEpiProblem

#Export inference methods
export AbstractEpiMethod, AbstractEpiOptMethod, AbstractEpiSamplingMethod

### Structs ###

export EpiProblem, EpiMethod

### Functions ###

# Export model generating functions
export generate_epiaware, generate_latent, generate_latent_infs, generate_observations

# Export support functions
export broadcast_rule, broadcast_n, condition_model, generate_observables

# Export methods functions
export apply_method

include("docstrings.jl")
include("types.jl")
include("functions.jl")
include("generate_models.jl")
include("EpiProblem.jl")
include("EpiMethod.jl")

end
