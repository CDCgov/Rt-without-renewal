@doc raw"
Apply steps defined by an `EpiMethod` to a `DynamicPPL.Model` object.


This function applies the steps defined by an `EpiMethod` object to a `DynamicPPL.Model` object. It iterates over the pre-sampler steps defined in the `EpiMethod` object and recursively applies them to the model. Finally, it applies the sampler step defined in the `EpiMethod` object to the model. The `prev_result` argument is used to pass the result obtained from applying the previous steps, if any.

# Arguments
- `method::EpiMethod`: The `EpiMethod` object containing the steps to be applied.
- `model::DynamicPPL.Model`: The `DynamicPPL.Model` object to which the steps will be applied.
- `prev_result`: The previous result obtained from applying the steps. Defaults to `nothing`.
- `kwargs...`: Additional keyword arguments that can be passed to the steps.

# Returns
- `prev_result`: The result obtained after applying the steps.
"
function EpiAwareBase.apply_method(
        model::DynamicPPL.Model, method::EpiMethod, prev_result = nothing; kwargs...)
    for pre_sampler in method.pre_sampler_steps
        prev_result = apply_method(model, pre_sampler, prev_result; kwargs...)
    end
    apply_method(model, method.sampler, prev_result; kwargs...)
end
