"""
Module for defining epidemiological models.
"""
module EpiInfModels

using ..EpiAwareBase

using ..EpiAwareUtils: scan, censored_pmf

using Turing, Distributions, DocStringExtensions, LinearAlgebra

#Export models
export EpiData, DirectInfections, ExpGrowthRate, Renewal, RenewalWithPopulation

#Export functions
export R_to_r, r_to_R, expected_Rt

include("docstrings.jl")
include("EpiData.jl")
include("DirectInfections.jl")
include("ExpGrowthRate.jl")
include("Renewal.jl")
include("utils.jl")

end
