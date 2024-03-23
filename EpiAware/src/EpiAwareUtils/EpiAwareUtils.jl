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
export scan, spread_draws, create_discrete_pmf, HalfNormal

include("docstrings.jl")
include("pmfs.jl")
include("distributions.jl")
include("scan.jl")
include("priors.jl")
include("post-inference.jl")

end
