module EpiModels

"""
Module for defining epidemiological models.
"""

include("../EpiAwareBase/EpiAwareBase.jl")
import .EpiAwareBase: AbstractEpiModel, generate_latent_infs

include("../EpiAwareUtils/EpiAwareUtils.jl")
import .EpiAwareUtils: scan

using Turing, Distributions, DocStringExtensions, QuadGK

export EpiData, DirectInfections, ExpGrowthRate, Renewal,
       generate_latent_infs, R_to_r, r_to_R, create_discrete_pmf

include("epidata.jl")
include("directinfections.jl")
include("expgrowthrate.jl")
include("renewal.jl")
include("utils.jl")

end
