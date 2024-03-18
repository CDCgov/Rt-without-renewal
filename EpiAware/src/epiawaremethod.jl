"""
`EpiMethod` represents a method for performing EpiAware inference and/or generative
modelling, which combines a sequence of optimization steps to pass initialisation
information to a sampler method.
"""
@kwdef struct EpiMethod{
    O <: AbstractEpiOptMethod, S <: AbstractEpiSamplingMethod} <:
              AbstractEpiMethod
    pre_sampler_steps::Vector{O}
    sampler::S
end
