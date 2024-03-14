module EpiAwareUtils

"""
Module for defining utility functions.
"""

include("../EpiAwareBase/EpiAwareBase.jl")
using .EpiAwareBase

import DataFramesMeta: DataFrame, @rename!
import Turing: Chains
import Distributions: Distribution, cdf

using DocStringExtensions, QuadGK

export scan, spread_draws, create_discrete_pmf

include("prior-tools.jl")
include("distributions.jl")
include("scan.jl")
include("post-inference.jl")

end
