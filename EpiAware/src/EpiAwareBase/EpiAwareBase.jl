"""
Module for defining abstract epidemiological types.
"""
module EpiAwareBase

using DocStringExtensions

### Abstract types ###

#Export models
export AbstractModel, AbstractEpiModel, AbstractLatentModel, AbstractObservationModel

# Export Turing-based models
export AbstractTuringEpiModel, AbstractTuringLatentModel, AbstractTuringIntercept,
       AbstractTuringObservationModel

# Export support types
export AbstractBroadcastRule

#Export problems
export AbstractEpiProblem

#Export inference methods
export AbstractEpiMethod, AbstractEpiOptMethod, AbstractEpiSamplingMethod

### Structs ###

export EpiProblem, EpiMethod, EpiAwareObservables

### Functions ###

# Export model generating functions
export generate_latent, generate_infections, generate_observations, generate_epiaware

# Export support functions
export broadcast_rule, broadcast_n, condition_model, generated_observables

# Export methods functions
export apply_method, _apply_method

include("docstrings.jl")
include("types.jl")
include("functions.jl")
include("generate_models.jl")
include("EpiProblem.jl")
include("EpiMethod.jl")
include("EpiAwareObservables.jl")
include("apply_method.jl")

end
