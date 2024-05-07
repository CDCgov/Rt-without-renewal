@doc raw"
The `TransformLatentModel` struct represents a latent model that applies a transformation function to the latent variables generated by another latent model.

## Constructors

- `TransformLatentModel(model, trans_function)`: Constructs a `TransformLatentModel` instance with the specified latent model and transformation function.
- `TransformLatentModel(; model, trans_function)`: Constructs a `TransformLatentModel` instance with the specified latent model and transformation function using named arguments.

## Example

```julia
using EpiAware, Distributions
trans = TransformLatentModel(Intercept(Normal(2, 0.2)), x -> x .|> exp)
trans_model = generate_latent(trans, 5)
trans_model()
```
"
@kwdef struct TransformLatentModel{M <: AbstractTuringLatentModel, F <: Function} <:
              AbstractTuringLatentModel
    "The latent model to transform."
    model::M
    "The transformation function."
    trans_function::F
end

"""
    generate_latent(model::TransformLatentModel, n)

Generate latent variables using the specified `TransformLatentModel`.

# Arguments
- `model::TransformLatentModel`: The `TransformLatentModel` to generate latent variables from.
- `n`: The number of latent variables to generate.

# Returns
- `transformed`: The transformed latent variables.
- `latent_aux`: Additional auxiliary variables generated by the underlying latent model.

"""
@model function EpiAwareBase.generate_latent(model::TransformLatentModel, n)
    @submodel untransformed, latent_aux = generate_latent(model.model, n)
    latent = model.trans_function(untransformed)
    return latent, (; untransformed, latent_aux)
end
