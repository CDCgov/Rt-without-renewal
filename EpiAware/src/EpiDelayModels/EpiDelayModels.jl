"""
Module for defining delay distribution models.
"""
module EpiDelayModels

using ..EpiAwareBase

using ..EpiAwareUtils: censored_pmf

using Turing, DocStringExtensions

#Export models
export FixedDelay

include("docstrings.jl")
include("FixedDelay.jl")

end
