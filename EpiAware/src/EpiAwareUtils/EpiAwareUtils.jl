"""
Module for defining utility functions.
"""
module EpiAwareUtils

using ..EpiAwareBase

using DataFramesMeta: DataFrame, @rename!
using Turing: Chains, generated_quantities
using DynamicPPL: Model
using MCMCChains: Chains
using Random: AbstractRNG

using Distributions, DocStringExtensions, QuadGK, Statistics

#Export Structures
export HalfNormal, DirectSample

#Export functions
export scan, spread_draws, censored_pmf

include("docstrings.jl")
include("censored_pmf.jl")
include("HalfNormal.jl")
include("scan.jl")
include("DirectSample.jl")
include("generate_observables.jl")
include("post-inference.jl")

end
