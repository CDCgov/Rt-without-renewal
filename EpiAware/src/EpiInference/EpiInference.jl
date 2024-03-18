
"""
Module for defining inference methods.
"""
module EpiInference

using ..EpiAwareBase: AbstractEpiMethod, AbstractEpiOptMethod,
                      AbstractEpiSamplingMethod
using Pathfinder: pathfinder, PathfinderResult

using DynamicPPL, DocStringExtensions

export AbstractNUTSMethod
export ManyPathfinderMethod
export manypathfinder

include("docstrings.jl")
include("manypathfinder.jl")
include("nuts.jl")

end
