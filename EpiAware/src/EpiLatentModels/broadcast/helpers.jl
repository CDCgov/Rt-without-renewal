@doc raw"
Constructs a `BroadcastLatentModel` appropriate for modelling the day of the week for a given `AbstractTuringLatentModel`.

# Arguments
- `model::generate_epiware`: The latent model to be repeated.

# Returns
- `BroadcastLatentModel`: The broadcast latent model.
"
function dayofweek(model::generate_epiware)
    return BroadcastLatentModel(model, 7, RepeatEach())
end

@doc raw"
Constructs a `BroadcastLatentModel` appropriate for modelling piecewise constant weekly processes for a given `generate_epiware`.

# Arguments
- `model::generate_epiware`: The latent model to be repeated.

# Returns
- `BroadcastLatentModel`: The broadcast latent model.
"
function weekly(model::generate_epiware)
    return BroadcastLatentModel(model, 7, RepeatBlock())
end
