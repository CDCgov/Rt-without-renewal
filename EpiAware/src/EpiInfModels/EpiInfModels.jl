"""
Module for defining epidemiological models.
"""
module EpiInfModels

using ..EpiAwareBase
using ..EpiAwareUtils

using Turing, Distributions, DocStringExtensions, LinearAlgebra, LogExpFunctions,
      OrdinaryDiffEq

#Export models
export EpiData, DirectInfections, ExpGrowthRate, Renewal, InfectionODEProcess

#Export parameter type
export ODEParams

#Export functions
export R_to_r, r_to_R, expected_Rt

include("docstrings.jl")
include("EpiData.jl")
include("DirectInfections.jl")
include("ExpGrowthRate.jl")
include("RenewalSteps.jl")
include("Renewal.jl")
include("InfectionODEProcess.jl")
include("utils.jl")

end
