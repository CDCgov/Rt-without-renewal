@doc raw"
Constructs a `BroadcastLatentModel` appropriate for modelling the day of the week for a given `AbstractTuringLatentModel`.

# Arguments
- `model::AbstractTuringLatentModel`: The latent model to be repeated.

# Returns
- `BroadcastLatentModel`: The broadcast latent model.
"
function dayofweek(model::AbstractTuringLatentModel)
    return BroadcastLatentModel(model, 7, RepeatEach())
end

@doc raw"
Constructs a `BroadcastLatentModel` appropriate for modelling piecewise constant weekly processes for a given `AbstractTuringLatentModel`.

# Arguments
- `model::AbstractTuringLatentModel`: The latent model to be repeated.

# Returns
- `BroadcastLatentModel`: The broadcast latent model.
"
function broadcast_weekly(model::AbstractTuringLatentModel)
    return BroadcastLatentModel(model, 7, RepeatBlock())
end
