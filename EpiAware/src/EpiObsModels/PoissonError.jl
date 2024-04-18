@doc raw"
The `PoissonError` struct represents an observation model for Poisson errors. It
    is a subtype of `AbstractTuringObservationModel`.

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
struct PoissonError{T <: AbstractFloat} <: AbstractTuringObservationModel
    "The positive shift value."
    pos_shift::T

    function PoissonError(; pos_shift::AbstractFloat = 0.0)
        @assert pos_shift>=0.0 "The positive shift value must be non-negative."
        new{typeof(pos_shift)}(pos_shift)
    end
end

@doc raw"
Generate observations using the `PoissonError` observation model.

# Arguments
- `obs_model::PoissonError`: The observation model.
- `y_t`: The observed values.
- `Y_t`: The true values.

# Returns
- `y_t`: The generated observations.
- An empty named tuple.
"
@model function EpiAwareBase.generate_observations(obs_model::PoissonError, y_t, Y_t)
    if ismissing(y_t)
        y_t = Vector{Int}(undef, length(Y_t))
    end

    for i in eachindex(y_t)
        y_t[i] ~ Poisson(Y_t[i] + obs_model.pos_shift)
    end

    return y_t, NamedTuple()
end
