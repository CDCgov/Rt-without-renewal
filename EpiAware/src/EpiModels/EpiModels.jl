module EpiModels

"""
Module for defining epidemiological models.
"""

include("../EpiAwareBase/EpiAwareBase.jl")
import .EpiAwareBase: AbstractModel, AbstractEpiModel, generate_latent_infs

include("../EpiAwareUtils/EpiAwareUtils.jl")
import .EpiAwareUtils: scan, create_discrete_pmf

using Turing, Distributions, DocStringExtensions, LinearAlgebra

export EpiData, DirectInfections, ExpGrowthRate, Renewal,
       R_to_r, r_to_R, generate_latent_infs

include("epidata.jl")
include("directinfections.jl")
include("expgrowthrate.jl")
include("renewal.jl")
include("utils.jl")

end
