# Define the Priors type alias
const Priors = Union{Distribution, Vector{<:Distribution}, Product}

include("randomwalk.jl")
include("autoregressive.jl")
include("difflatentmodel.jl")
