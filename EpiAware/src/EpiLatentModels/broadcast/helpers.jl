@doc raw"
Constructs a `BroadcastLatentModel` appropriate for modelling the day of the week for a given `AbstractTuringLatentModel`.

# Arguments
- `model::AbstractTuringLatentModel`: The latent model to be repeated.
- `link::Function`: The link function to transform the latent model _before_ broadcasting
to periodic weekly. Default is `x -> 7 * softmax(x)` which implements constraint
of the sum week effects to be 7.

# Returns
- `BroadcastLatentModel`: The broadcast latent model.
"
function broadcast_dayofweek(model::AbstractTuringLatentModel; link = x -> 7 * softmax(x))
    transformed_model = TransformLatentModel(model, link)
    return BroadcastLatentModel(transformed_model, 7, RepeatEach())
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
