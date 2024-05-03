@doc raw"
The `CombineLatentModels` struct.

This struct is used to combine multiple latent models into a single latent model.

# Constructors

- `CombineLatentModels(models::M) where {M <: AbstractVector{<:AbstractTuringLatentModel}}`: Constructs a `CombineLatentModels` instance with specified models, ensuring that there are at least two models.

# Examples

```julia
using EpiAware, Distributions
combined_model = CombineLatentModels([Intercept(Normal(2, 0.2)), AR()])
latent_model = generate_latent(combined_model, 10)
latent_model()
rand(latent_model)
```
"
@kwdef struct CombineLatentModels{M <: AbstractVector{<:AbstractTuringLatentModel}} <: AbstractTuringLatentModel
    "A vector of latent models"
    models::M

    function CombineLatentModels(models::M) where {M <: AbstractVector{<:AbstractTuringLatentModel}}
        @assert length(models)>1 "At least two models are required"
        return new{AbstractVector{<:AbstractTuringLatentModel}}(models)
    end
end

@doc raw"
Generate latent variables using a combination of multiple latent models.

# Arguments
- `latent_models::CombineLatentModels`: An instance of the `CombineLatentModels` type representing the collection of latent models.
- `n`: The number of latent variables to generate.

# Returns
- `combined_latents`: The combined latent variables generated from all the models.
- `latent_aux`: A tuple containing the auxiliary latent variables generated from each individual model.

# Example
"
function EpiAwareBase.generate_latent(latent_models::CombineLatentModels, n)
    @submodel final_latent, latent_aux = _accumulate_latents(latent_models.models, 1, fill(0.0, n), [])

    return final_latent, (; latent_aux...)
end

@model function _accumulate_latents(models, index, acc_latent, acc_aux)
    if index > length(models)
        return acc_latent, (; acc_aux...)
    else
        @submodel latent, new_aux = generate_latent(models[index], n)
        @submodel updated_latent, updated_aux = _accumulate_latents(models, index + 1, acc_latent .+ latent, (; acc_aux..., new_aux...))
        return updated_latent,(; updated_aux...)
    end
end
