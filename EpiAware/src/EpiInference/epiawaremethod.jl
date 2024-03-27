
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
