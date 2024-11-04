"""
Module for defining epidemiological models.
"""
module EpiInfModels

using ..EpiAwareBase
using ..EpiAwareUtils

using Turing, Distributions, DocStringExtensions, LinearAlgebra, LogExpFunctions,
      SparseArrays, OrdinaryDiffEq

#Export parameter helpers
export EpiData

#Export ODE definitions
export SIRParams, SEIRParams

#Export models
export DirectInfections, ExpGrowthRate, Renewal, ODEProcess

#Export functions
export R_to_r, r_to_R, expected_Rt

include("docstrings.jl")
include("EpiData.jl")
include("DirectInfections.jl")
include("ExpGrowthRate.jl")
include("RenewalSteps.jl")
include("Renewal.jl")
include("odemodels/SIRParams.jl")
include("odemodels/SEIRParams.jl")
include("ODEProcess.jl")
include("utils.jl")

end
