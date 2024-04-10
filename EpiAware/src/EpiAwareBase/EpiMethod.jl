@doc raw"
`EpiMethod` represents a method for performing EpiAware inference and/or
    generative modelling, which combines a sequence of optimization steps to pass initialisation information to a sampler method.
"
struct EpiMethod{O <: AbstractEpiOptMethod, S <: AbstractEpiSamplingMethod} <:
       AbstractEpiMethod
    "Pre-sampler optimization steps."
    pre_sampler_steps::Vector{O}
    "Sampler method."
    sampler::S
end
