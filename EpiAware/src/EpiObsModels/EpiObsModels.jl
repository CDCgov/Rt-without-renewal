"""
Module for defining observation models.
"""
module EpiObsModels

using ..EpiAwareBase

using ..EpiAwareUtils: censored_pmf, HalfNormal

using Turing, Distributions, DocStringExtensions, SparseArrays

export NegativeBinomialError, LatentDelay

include("docstrings.jl")
include("LatentDelay.jl")
include("NegativeBinomialError.jl")
include("utils.jl")

end
