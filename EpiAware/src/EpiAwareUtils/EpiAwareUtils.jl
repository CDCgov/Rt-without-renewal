"""
Module for defining utility functions.
"""
module EpiAwareUtils

using ..EpiAwareBase

using DataFramesMeta: DataFrame, @rename!
using DynamicPPL: Model, fix, condition, @submodel, @model
using MCMCChains: Chains
using Random: AbstractRNG
using Tables: rowtable

using Distributions, DocStringExtensions, QuadGK, Statistics, Turing

#Export Structures
export HalfNormal, DirectSample

#Export functions
export scan, spread_draws, censored_pmf, get_param_array, prefix_submodel

include("docstrings.jl")
include("censored_pmf.jl")
include("HalfNormal.jl")
include("scan.jl")
include("prefix_submodel.jl")
include("turing-methods.jl")
include("DirectSample.jl")
include("post-inference.jl")
include("get_param_array.jl")

end
