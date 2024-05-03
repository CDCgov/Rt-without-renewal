@doc raw"
The `TransformLatentModel` struct represents a latent model that applies a transformation function to the latent variables generated by another latent model.

## Constructors

- `TransformLatentModel(model::
"
@kwdef struct TransformLatentModel{M <: AbstractTuringLatentModel, F <: Function} <: AbstractTuringLatentModel
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
    @submodel latent, latent_aux = generate_latent(model.model, n)
    transformed = model.trans_function(latent)

    return transformed, (; latent_aux...)
end
