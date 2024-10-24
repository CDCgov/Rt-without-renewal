@doc raw"
The `TransformObservationModel` struct represents an observation model that applies a transformation function to the expected observations before passing them to the underlying observation model.

## Fields
- `model::M`: The underlying observation model.
- `transform::F`: The transformation function applied to the expected observations.

## Constructors
- `TransformObservationModel(model::M, transform::F = x -> log1pexp.(x)) where {M <: AbstractTuringObservationModel, F <: Function}`: Constructs a `TransformObservationModel` instance with the specified observation model and a default transformation function.
- `TransformObservationModel(; model::M, transform::F = x -> log1pexp.(x)) where {M <: AbstractTuringObservationModel, F <: Function}`: Constructs a `TransformObservationModel` instance using named arguments.
- `TransformObservationModel(model::M; transform::F = x -> log1pexp.(x)) where {M <: AbstractTuringObservationModel, F <: Function}`: Constructs a `TransformObservationModel` instance with the specified observation model and a default transformation function.

## Example

```julia
using EpiAware, Distributions, LogExpFunctions

trans_obs = TransformObservationModel(NegativeBinomialError())
gen_obs = generate_observations(trans_obs, missing, fill(10.0, 30))
gen_obs()
```
"
@kwdef struct TransformObservationModel{
    M <: AbstractTuringObservationModel, F <: Function} <: AbstractTuringObservationModel
    "The underlying observation model."
    model::M
    "The transformation function. The default is `log1pexp` which is the softplus transformation"
    transform::F = x -> log1pexp.(x)
end

function TransformObservationModel(model::M;
        transform::F = x -> log1pexp.(x)) where {
        M <: AbstractTuringObservationModel, F <: Function}
    return TransformObservationModel(model, transform)
end

@doc raw"
Generates observations or accumulates log-likelihood based on the `TransformObservationModel`. 

## Arguments
- `obs::TransformObservationModel`: The TransformObservationModel.
- `y_t`: The current state of the observations.
- `Y_t`: The expected observations.

## Returns
- `y_t`: The updated observations.
"
@model function EpiAwareBase.generate_observations(
        obs::TransformObservationModel, y_t, Y_t
)
    transformed_Y_t = obs.transform(Y_t)

    @submodel y_t = generate_observations(obs.model, y_t, transformed_Y_t)

    return y_t
end
