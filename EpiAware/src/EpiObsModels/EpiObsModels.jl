"""
Module for defining observation models.
"""
module EpiObsModels

using ..EpiAwareBase

using ..EpiAwareUtils: create_discrete_pmf, HalfNormal

using Turing, Distributions, DocStringExtensions, SparseArrays

export NegativeBinomialError

include("docstrings.jl")
include("NegativeBinomialError.jl")
include("utils.jl")

end
