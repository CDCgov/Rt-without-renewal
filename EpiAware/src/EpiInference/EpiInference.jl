"""
Module for defining inference methods.
"""
module EpiInference

using ..EpiAwareBase: AbstractEpiMethod, AbstractEpiOptMethod, AbstractEpiSamplingMethod
import ..EpiAwareBase: _apply_method

using Pathfinder: pathfinder, PathfinderResult
using DynamicPPL, DocStringExtensions, ADTypes, AbstractMCMC, Turing
import ADTypes: AbstractADType
import AbstractMCMC: AbstractMCMCEnsemble
import AdvancedHMC: AbstractMetric, DenseEuclideanMetric, DiagEuclideanMetric
#Export inference methods
export EpiMethod, ManyPathfinder, NUTSampler

#Export functions
export manypathfinder

include("docstrings.jl")
include("epiawaremethod.jl")
include("manypathfinder.jl")
include("nuts.jl")

end
