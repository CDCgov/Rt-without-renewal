@doc raw"
Constructs a `BroadcastLatentModel` appropriate for modelling the day of the week for a given `AbstractLatentModel`.

# Arguments
- `model::AbstractLatentModel`: The latent model to be repeated.

# Returns
- `BroadcastLatentModel`: The broadcast latent model.
"
function dayofweek(model::AbstractLatentModel)
    return BroadcastLatentModel(model, 7, RepeatEach())
end

@doc raw"
Constructs a `BroadcastLatentModel` appropriate for modelling piecewise constant weekly processes for a given `AbstractLatentModel`.

# Arguments
- `model::AbstractLatentModel`: The latent model to be repeated.

# Returns
- `BroadcastLatentModel`: The broadcast latent model.
"
function weekly(model::AbstractLatentModel)
    return BroadcastLatentModel(model, 7, RepeatBlock())
end
