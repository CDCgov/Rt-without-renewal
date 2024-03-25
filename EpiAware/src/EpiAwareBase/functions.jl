@doc raw"
This function is used to define the behavior of broadcasting for a specific type of `AbstractBroadcastRule`.

The `broadcast_rule` function implements a model of broadcasting a latent process. Which model of broadcasting to be implemented is set by the type of `broadcast_rule`. If no implemention is defined for the given `broadcast_rule`, then `EpiAware` will return a warning and return `nothing`.
"
function broadcast_rule(broadcast_rule::AbstractBroadcastRule)
    @info "No concrete implementation for broadcast_rule is defined."
    return nothing
end

@doc raw"
This function is used to define the behavior of broadcasting for a specific type of `AbstractBroadcastRule`.

The `broadcast_n` function returns the length of the latent periods to generate using the given `broadcast_rule`. Which model of broadcasting to be implemented is set by the type of `broadcast_rule`. If no implemention is defined for the given `broadcast_rule`, then `EpiAware` will return a warning and return `nothing`.
"
function broadcast_n(broadcast_rule::AbstractBroadcastRule)
    @info "No concrete implementation for broadcast_n is defined."
    return nothing
end
