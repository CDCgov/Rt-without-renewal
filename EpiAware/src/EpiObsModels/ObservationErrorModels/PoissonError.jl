@doc raw"
The `PoissonError` struct represents an observation model for Poisson errors. It
is a subtype of `AbstractTuringObservationErrorModel`.

## Constructors
- `PoissonError()`: Constructs a `PoissonError` object.

## Examples
```julia
using Distributions, Turing, EpiAware
poi = PoissonError()
poi_model = generate_observations(poi, missing, fill(10, 10))
rand(poi_model)
```
"
struct PoissonError <: AbstractTuringObservationErrorModel
end

@doc raw"
The observation error model for Poisson errors. This function generates the
observation error model based on the Poisson error model.
"
function observation_error(obs_model::PoissonError, Y_t)
    return Poisson(Y_t)
end
