module EpiInference

"""
Module for defining inference methods.
"""

using Pathfinder: pathfinder, PathfinderResult

using DynamicPPL, DocStringExtensions

export manypathfinder

include("docstrings.jl")
include("manypathfinder.jl")

end
