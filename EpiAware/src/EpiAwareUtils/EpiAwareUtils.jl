module EpiAwareUtils

"""
Module for defining utility functions.
"""

using ..EpiAwareBase

using DataFramesMeta: DataFrame, @rename!
using Turing: Chains
using Distributions: Distribution, cdf, Normal, truncated

using DocStringExtensions, QuadGK

export scan, spread_draws, create_discrete_pmf

include("docstrings.jl")
include("prior-tools.jl")
include("distributions.jl")
include("scan.jl")
include("post-inference.jl")

end
