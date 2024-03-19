"""
Module for defining observation models.
"""
module EpiObsModels

using ..EpiAwareBase

using ..EpiAwareUtils: create_discrete_pmf

using Turing, Distributions, DocStringExtensions, SparseArrays

#Export models
export DelayObservations

#Export functions
export default_delay_obs_priors

include("docstrings.jl")
include("delayobservations.jl")
include("utils.jl")

end
