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
Apply the inference/generative method `method` to the `AbstractEpiModel` object `mdl`.

# Arguments
- `model::AbstractEpiModel`: The model to apply the method to.
- `method::AbstractEpiMethod`: The epidemiological method to apply.
- `prev_result`: The previous result of the method.
- `kwargs`: Additional keyword arguments passed to the method.

# Returns
- `nothing`: If no concrete implementation is defined for the given `method`.
"""
function apply_method(model::AbstractEpiModel, method::AbstractEpiMethod,
        prev_result = nothing; kwargs...)
    @info "No concrete implementation for `apply_method` is defined."
    return nothing
end

@doc raw"
Condition a model on fixed (i.e to a value) and conditioned (i.e to data) parameters.

# Returns
- `model`: The conditioned model.
"
function condition_model(model, fix_parameters, condition_parameters)
    @info "No concrete implementation for `condition_model` is defined."
    return model
end

@doc raw"
Generate observables from a given model and solution default to just returning the solution.
"
function generated_observables(model, solution)
    (samples = solution,)
end
