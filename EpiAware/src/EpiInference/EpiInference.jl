module EpiInference

"""
Module for defining inference methods.
"""

using Pathfinder: pathfinder, PathfinderResult

using DynamicPPL, DocStringExtensions

export manypathfinder

include("manypathfinder.jl")

end
