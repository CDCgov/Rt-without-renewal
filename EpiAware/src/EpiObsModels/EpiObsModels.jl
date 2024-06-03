"""
Module for defining observation models.
"""
module EpiObsModels

using ..EpiAwareBase

using ..EpiAwareUtils: censored_pmf, HalfNormal

using Turing, Distributions, DocStringExtensions, SparseArrays

export PoissonError, NegativeBinomialError, LatentDelay, Ascertainment

include("docstrings.jl")
include("LatentDelay.jl")
include("ascertainment/Ascertainment.jl")
include("ascertainment/helpers.jl")
include("PoissonError.jl")
include("NegativeBinomialError.jl")
include("utils.jl")

end
