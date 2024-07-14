"""
Module for defining utility functions.
"""
module EpiAwareUtils

using ..EpiAwareBase

using DataFramesMeta: DataFrame, @rename!
using MCMCChains: Chains, get_sections, chainscat
using Tables: rowtable
using AbstractMCMC: bundle_samples

using Distributions, DocStringExtensions, QuadGK, Statistics, Turing, Random, DynamicPPL

#Export Structures
export HalfNormal, DirectSample

#Export functions
export scan, spread_draws, censored_pmf, get_param_array, prefix_submodel

# Export accumulate tools
export get_state, accumulate_scan

# Export custom prediction
export predict, PredictContext

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
include("predict.jl")

end
