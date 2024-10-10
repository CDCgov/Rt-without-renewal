@doc raw"

Create an `Ascertainment` object that models the ascertainment process based on the day of the week.

# Arguments
- `model::AbstractTuringObservationModel`: The observation model to be used.
- `latent_model::AbstractTuringLatentModel`: The latent model to be used. Default is `HierarchicalNormal()` which is a hierarchical normal distribution.
- `transform`: The transform function to be used. Default is `(x, y) -> x .* y`.
This function is used to transform the latent model _after_ broadcasting to
periodic weekly has been applied.
- `latent_prefix`: The prefix to be used for the latent model. Default is `\"DayofWeek\"`.

# Returns
- `Ascertainment`: The `Ascertainment` object that models the ascertainment process based on the day of the week.

# Examples

```julia
using EpiAware
obs = ascertainment_dayofweek(PoissonError())
gen_obs = generate_observations(obs, missing, fill(100, 14))
gen_obs()
rand(gen_obs)
```
"
function ascertainment_dayofweek(model::AbstractTuringObservationModel;
        latent_model::AbstractTuringLatentModel = HierarchicalNormal(),
        transform = (x, y) -> x .* y, latent_prefix = "DayofWeek")
    return Ascertainment(model, broadcast_dayofweek(latent_model), transform, latent_prefix)
end
