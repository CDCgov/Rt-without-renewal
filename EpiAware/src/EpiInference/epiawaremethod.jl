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

"""
Apply steps definded by an `EpiMethod` to a `DynamicPPL.Model` object.
"""
function _apply_method(
        method::EpiMethod, mdl::DynamicPPL.Model, prev_result = nothing; kwargs...)
    for pre_sampler in method.pre_sampler_steps
        prev_result = _apply_method(pre_sampler, mdl, prev_result; kwargs...)
    end
    _apply_method(method.sampler, mdl, prev_result; kwargs...)
end
