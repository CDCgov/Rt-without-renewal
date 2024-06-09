"""
Module for defining observation models.
"""
module EpiObsModels

using ..EpiAwareBase

using ..EpiAwareUtils: censored_pmf, HalfNormal

using ..EpiLatentModels: HierarchicalNormal, broadcast_dayofweek

using Turing, Distributions, DocStringExtensions, SparseArrays

# Abstract observation model
export AbstractTuringObservationErrorModel, generate_observation_error_priors,
       observation_error

# Observation models
export PoissonError, NegativeBinomialError

# Observation model modifiers
export LatentDelay, Ascertainment, StackObservationModels

# helper functions
export ascertainment_dayofweek

include("docstrings.jl")
include("LatentDelay.jl")
include("ascertainment/Ascertainment.jl")
include("ascertainment/helpers.jl")
include("StackObservationModels.jl")
include("ObservationErrorModels/AbstractTuringObservationModel.jl")
include("ObservationErrorModels/NegativeBinomialError.jl")
include("ObservationErrorModels/PoissonError.jl")
include("utils.jl")

end
