"""
Module for defining utility functions.
"""
module EpiAwareUtils

using ..EpiAwareBase

using DataFramesMeta: DataFrame, @rename!
using Turing: Chains
using Distributions: Distribution, cdf, rand, logpdf, cdf, quantile, minimum,
                     maximum, insupport

using DocStringExtensions, QuadGK

#Export functions
export scan, spread_draws, censored_pmf, HalfNormal

include("docstrings.jl")
include("censored_pmf.jl")
include("distributions.jl")
include("scan.jl")
include("post-inference.jl")

end
