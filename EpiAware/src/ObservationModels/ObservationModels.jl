module ObservationModels

"""
Module for defining observation models.
"""

include("../EpiAwareBase/EpiAwareBase.jl")
using .EpiAwareBase

using Turing, Distributions, DocStringExtensions, SparseArrays

export DelayObservations, default_delay_obs_priors

include("delayobservations.jl")
include("utils.jl")

end
