"""
Module for defining observation models.
"""
module EpiObsModels

using ..EpiAwareBase

using ..EpiAwareUtils: censored_pmf, HalfNormal

using ..EpiLatentModels: HierarchicalNormal, broadcast_dayofweek

using Turing, Distributions, DocStringExtensions, SparseArrays

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
include("PoissonError.jl")
include("NegativeBinomialError.jl")
include("utils.jl")

end
