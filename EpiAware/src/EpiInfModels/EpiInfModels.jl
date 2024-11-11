"""
Module for defining epidemiological models.
"""
module EpiInfModels

using ..EpiAwareBase
using ..EpiAwareUtils

using LogExpFunctions: xexpy

using Turing, Distributions, DocStringExtensions, LinearAlgebra, OrdinaryDiffEq

#Export parameter helpers
export EpiData

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
include("ODEProcess.jl")
include("utils.jl")

end
