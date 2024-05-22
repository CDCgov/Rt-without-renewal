"""
Module for defining utility functions.
"""
module EpiAwareUtils

using ..EpiAwareBase

using DataFramesMeta: DataFrame, @rename!
using DynamicPPL: Model, fix, condition
using MCMCChains: Chains
using Random: AbstractRNG

using Distributions, DocStringExtensions, QuadGK, Statistics, Turing

#Export Structures
export HalfNormal, DirectSample

#Export functions
export scan, spread_draws, censored_pmf, get_param_array

include("docstrings.jl")
include("censored_pmf.jl")
include("HalfNormal.jl")
include("scan.jl")
include("turing-methods.jl")
include("DirectSample.jl")
include("post-inference.jl")
include("get_param_array.jl")

end
