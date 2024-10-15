"""
Module for defining utility functions.
"""
module EpiAwareUtils

using ..EpiAwareBase

using DataFramesMeta: DataFrame, @rename!
using DynamicPPL: Model, fix, condition, @submodel, @model
using MCMCChains: Chains
using Random: AbstractRNG, randexp
using Tables: rowtable
using SpecialFunctions: loggamma
using StatsFuns: poispdf, poislogpdf, poiscdf, poisccdf
using StatsFuns: nbinompdf, nbinomlogpdf, nbinomcdf, nbinomccdf, nbinomlogcdf,
                 nbinomlogccdf, nbinominvlogcdf, nbinominvlogccdf

using Distributions, DocStringExtensions, QuadGK, Statistics, Turing

#Export Structures
export HalfNormal, DirectSample, SafePoisson, SafeNegativeBinomial

#Export functions
export scan, spread_draws, censored_cdf, censored_pmf, get_param_array, prefix_submodel, ∫F

# Export accumulate tools
export get_state, accumulate_scan

include("docstrings.jl")
include("censored_pmf.jl")
include("HalfNormal.jl")
include("scan.jl")
include("accumulate_scan.jl")
include("prefix_submodel.jl")
include("turing-methods.jl")
include("DirectSample.jl")
include("post-inference.jl")
include("get_param_array.jl")
include("SafePoisson.jl")
include("SafeNegativeBinomial.jl")

end
