module EpiObsModels

"""
Module for defining observation models.
"""

using ..EpiAwareBase

using ..EpiAwareUtils: create_discrete_pmf

using Turing, Distributions, DocStringExtensions, SparseArrays

export DelayObservations, default_delay_obs_priors

include("delayobservations.jl")
include("utils.jl")

end
