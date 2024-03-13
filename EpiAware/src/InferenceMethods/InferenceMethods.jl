module InferenceMethods

"""
Module for defining inference methods.
"""

import Pathfinder: pathfinder, PathfinderResult

using DynamicPPL, DocStringExtensions

export manypathfinder

include("manypathfinder.jl")

end
