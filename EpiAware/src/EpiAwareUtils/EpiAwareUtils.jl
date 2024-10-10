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
import Base: eltype

using Distributions, DocStringExtensions, QuadGK, Statistics, Turing

#Export Structures
export HalfNormal, DirectSample, SafePoisson, SafeNegativeBinomial, RealValued,
       RealUnivariateDistribution

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
include("RealValued.jl")
include("SafePoisson.jl")
include("SafeNegativeBinomial.jl")

end
