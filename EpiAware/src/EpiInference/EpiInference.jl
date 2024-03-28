"""
Module for defining inference methods.
"""
module EpiInference

using ..EpiAwareBase

using Pathfinder: pathfinder, PathfinderResult
using AdvancedHMC: AbstractMetric, DenseEuclideanMetric, DiagEuclideanMetric

using DynamicPPL, DocStringExtensions, ADTypes, AbstractMCMC, Turing

#Export inference methods
export ManyPathfinder, NUTSampler

#Export functions
export manypathfinder

include("docstrings.jl")
include("epiawaremethod.jl")
include("ManyPathfinder.jl")
include("nuts.jl")

end
