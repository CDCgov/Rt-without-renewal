module EpiAwareUtils

"""
Module for defining utility functions.
"""

include("../EpiAwareBase/EpiAwareBase.jl")
import .EpiAwareBase: AbstractModel

import DataFramesMeta: DataFrame, @rename!
import Turing: Chains

using DocStringExtensions

export scan, spread_draws

include("scan.jl")
include("post-inference.jl")

end
