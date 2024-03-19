"""
Module for defining epidemiological models.
"""
module EpiInfModels

using ..EpiAwareBase

using ..EpiAwareUtils: scan, create_discrete_pmf

using Turing, Distributions, DocStringExtensions, LinearAlgebra

#Export models
export EpiData, DirectInfections, ExpGrowthRate, Renewal

#Export functions
export R_to_r, r_to_R

include("docstrings.jl")
include("epidata.jl")
include("directinfections.jl")
include("expgrowthrate.jl")
include("renewal.jl")
include("utils.jl")

end
