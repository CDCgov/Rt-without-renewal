@doc raw"
This function is used to define the behavior of broadcasting for a specific type of `AbstractBroadcastRule`.

The `broadcast_rule` function implements a model of broadcasting a latent process. Which model of broadcasting to be implemented is set by the type of `broadcast_rule`. If no implemention is defined for the given `broadcast_rule`, then `EpiAware` will return a warning and return `nothing`.
"
function broadcast_rule(broadcast_rule::AbstractBroadcastRule, n, period)
    @info "No concrete implementation for broadcast_rule is defined."
    return nothing
end

@doc raw"
This function is used to define the behavior of broadcasting for a specific type of `AbstractBroadcastRule`.

The `broadcast_n` function returns the length of the latent periods to generate using the given `broadcast_rule`. Which model of broadcasting to be implemented is set by the type of `broadcast_rule`. If no implemention is defined for the given `broadcast_rule`, then `EpiAware` will return a warning and return `nothing`.
"
function broadcast_n(broadcast_rule::AbstractBroadcastRule, latent, n, period)
    @info "No concrete implementation for broadcast_n is defined."
    return nothing
end

"""
Apply the inference/generative method `method` to the `DynamicPPL.Model` object `mdl`.

# Arguments
- `method::AbstractEpiMethod`: The epidemiological method to apply.
- `mdl::DynamicPPL.Model`: The model to apply the method to.
- `prev_result`: The previous result of the method.
- `kwargs`: Additional keyword arguments passed to the method.

# Returns
- `nothing`: If no concrete implementation is defined for the given `method`.
"""
function _apply_method(method::AbstractEpiMethod, mdl::DynamicPPL.Model, prev_result;
        kwargs...)
    @info "No concrete implementation for `_apply_method` is defined."
    return nothing
end
