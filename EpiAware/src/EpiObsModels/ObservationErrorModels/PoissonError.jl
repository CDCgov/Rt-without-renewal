@doc raw"
The `PoissonError` struct represents an observation model for Poisson errors. It
is a subtype of `AbstractTuringObservationErrorModel`.

## Constructors
- `PoissonError(; pos_shift::AbstractFloat = 0.)`: Constructs a `PoissonError`
object with default values for the cluster factor prior and positive shift.

## Examples
```julia
using Distributions, Turing, EpiAware
poi = PoissonError()
poi_model = generate_observations(poi, missing, fill(10, 10))
rand(poi_model)
```
"
struct PoissonError{T <: AbstractFloat} <: AbstractTuringObservationErrorModel
    "The positive shift value."
    pos_shift::T

    function PoissonError(; pos_shift::AbstractFloat = 0.0)
        @assert pos_shift>=0.0 "The positive shift value must be non-negative."
        new{typeof(pos_shift)}(pos_shift)
    end
end

@doc raw"
The observation error model for Poisson errors. This function generates the
observation error model based on the Poisson error model with a positive shift.
"
function observation_error(obs_model::PoissonError, Y_t)
    return Poisson(Y_t + obs_model.pos_shift)
end
