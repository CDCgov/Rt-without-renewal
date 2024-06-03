@doc raw"

Create an `Ascertainment` object that models the ascertainment process based on the day of the week.

# Arguments
- `model::AbstractTuringObservationModel`: The observation model to be used.
- `latent_model::AbstractTuringLatentModel`: The latent model to be used. Default is `HierarchicalNormal()` which is a hierarchical normal distribution.
- `link`: The link function to be used. Default is `x -> 7 * softmax(x)`. This
provides a soft constraint on the latent model to ensure that the latent model
is restricted to the range of 0 to 7 for each day of the week.

# Returns
- `Ascertainment`: The `Ascertainment` object.

"
function ascertainment_dayofweek(model::AbstractTuringObservationModel;
        latent_model::AbstractTuringLatentModel = HierarchicalNormal(),
        link = x -> 7 * softmax(x))
    return Ascertainment(model, broadcast_dayofweek(latent_model), link)
end
