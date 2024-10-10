"""
Module for defining observation models.
"""
module EpiObsModels

using ..EpiAwareBase

using ..EpiAwareUtils

using ..EpiLatentModels: HierarchicalNormal, broadcast_dayofweek
using ..EpiLatentModels: broadcast_rule, PrefixLatentModel, RepeatEach

using Turing, Distributions, DocStringExtensions, SparseArrays, LinearAlgebra
using LogExpFunctions: log1pexp

# Observation error models
export PoissonError, NegativeBinomialError

# Observation error model functions
export generate_observation_error_priors, observation_error

# Observation model modifiers
export LatentDelay, Ascertainment, PrefixObservationModel, RecordExpectedObs
export Aggregate, TransformObservationModel

# Observation model manipulators
export StackObservationModels

# helper functions
export ascertainment_dayofweek

include("docstrings.jl")
include("modifiers/LatentDelay.jl")
include("modifiers/ascertainment/Ascertainment.jl")
include("modifiers/ascertainment/helpers.jl")
include("modifiers/Aggregate.jl")
include("modifiers/PrefixObservationModel.jl")
include("modifiers/RecordExpectedObs.jl")
include("modifiers/TransformObservationModel.jl")
include("StackObservationModels.jl")
include("ObservationErrorModels/methods.jl")
include("ObservationErrorModels/NegativeBinomialError.jl")
include("ObservationErrorModels/PoissonError.jl")
include("utils.jl")

end
