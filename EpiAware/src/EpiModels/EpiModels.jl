module EpiModels

"""
Module for defining epidemiological models.
"""

include("../EpiAwareBase/EpiAwareBase.jl")
using .EpiAwareBase

include("../EpiAwareUtils/EpiAwareUtils.jl")
import .EpiAwareUtils: scan

using Turing, Distributions, DocStringExtensions, QuadGK

export EpiData, DirectInfections, ExpGrowthRate, Renewal,
       R_to_r, r_to_R, create_discrete_pmf

include("epidata.jl")
include("directinfections.jl")
include("expgrowthrate.jl")
include("renewal.jl")
include("utils.jl")

end
