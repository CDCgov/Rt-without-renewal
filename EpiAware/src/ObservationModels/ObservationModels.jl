module ObservationModels

"""
Module for defining observation models.
"""

include("../EpiAwareBase/EpiAwareBase.jl")
import .EpiAwareBase: AbstractObservationModel, generate_observations

using Turing, Distributions, DocStringExtensions, SparseArrays

export DelayObservations, default_delay_obs_priors, generate_observations

include("delayobservations.jl")
include("utils.jl")

end
