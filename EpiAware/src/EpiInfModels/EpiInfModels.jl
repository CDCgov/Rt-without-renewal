"""
Module for defining epidemiological models.
"""
module EpiInfModels

using ..EpiAwareBase
import ..EpiAwareBase: _apply_method

using ..EpiAwareUtils: scan, censored_pmf

using Turing, Distributions, DocStringExtensions, LinearAlgebra

#Export models
export EpiData, DirectInfections, ExpGrowthRate, Renewal

#Export functions
export R_to_r, r_to_R

#Export methods
export DirectSample

include("docstrings.jl")
include("epidata.jl")
include("directinfections.jl")
include("expgrowthrate.jl")
include("renewal.jl")
include("utils.jl")
include("directsample.jl")

end
