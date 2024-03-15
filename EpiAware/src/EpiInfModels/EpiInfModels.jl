module EpiInfModels

"""
Module for defining epidemiological models.
"""

using ..EpiAwareBase

using ..EpiAwareUtils: scan, create_discrete_pmf

using Turing, Distributions, DocStringExtensions, LinearAlgebra

export EpiData, DirectInfections, ExpGrowthRate, Renewal,
       R_to_r, r_to_R

include("docstrings.jl")
include("epidata.jl")
include("directinfections.jl")
include("expgrowthrate.jl")
include("renewal.jl")
include("utils.jl")

end
