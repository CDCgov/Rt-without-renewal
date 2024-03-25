"""
Module for defining utility functions.
"""
module EpiAwareUtils

using ..EpiAwareBase

using DataFramesMeta: DataFrame, @rename!
using Turing: Chains
using Random: AbstractRNG

using Distributions, DocStringExtensions, QuadGK, Statistics

#Export Structures
export HalfNormal

#Export functions
export scan, spread_draws, censored_pmf

include("docstrings.jl")
include("censored_pmf.jl")
include("HalfNormal.jl")
include("scan.jl")
include("post-inference.jl")

end
