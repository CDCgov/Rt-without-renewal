"""
Module for defining observation models.
"""
module EpiObsModels

using ..EpiAwareBase

using ..EpiAwareUtils: censored_pmf, HalfNormal

using Turing, Distributions, DocStringExtensions, SparseArrays

# Observation models
export PoissonError, NegativeBinomialError

# Observation model modifiers
export LatentDelay, Ascertainment, StackObservationModels

include("docstrings.jl")
include("LatentDelay.jl")
include("Ascertainment.jl")
include("StackObservationModels.jl")
include("PoissonError.jl")
include("NegativeBinomialError.jl")
include("utils.jl")

end
