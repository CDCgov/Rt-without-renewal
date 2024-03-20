"""
Module for defining observation models.
"""
module EpiObsModels

using ..EpiAwareBase

using ..EpiAwareUtils: create_discrete_pmf, HalfNormal

using Turing, Distributions, DocStringExtensions, SparseArrays, Memoization

export NegativeBinomialError, LatentDelay

include("docstrings.jl")
include("LatentDelay.jl")
include("NegativeBinomialError.jl")
include("utils.jl")

end
