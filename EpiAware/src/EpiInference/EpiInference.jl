
"""
Module for defining inference methods.
"""
module EpiInference

using ..EpiAwareBase: AbstractEpiMethod, AbstractEpiOptMethod,
                      AbstractEpiSamplingMethod
using Pathfinder: pathfinder, PathfinderResult

using DynamicPPL, DocStringExtensions

#Export inference methods
export AbstractNUTSMethod, EpiMethod, ManyPathfinder

#Export functions
export manypathfinder

include("docstrings.jl")
include("epiawaremethod.jl")
include("manypathfinder.jl")
include("nuts.jl")

end
