@doc raw"
The `CombineLatentModels` struct.

This struct is used to combine multiple latent models into a single latent model. The inverse link function is applied to each latent model before combining.

# Constructors
- `CombineLatentModels(models::AbstractVector{<:AbstractTuringLatentModel}; inverse_link::Function = x -> x)`: Constructs a `CombineLatentModels` instance with a vector of models and a default or specified inverse link function applied uniformly to all models.

- `CombineLatentModels(models::M, inverse_links::F) where {M <: AbstractVector{<:AbstractTuringLatentModel}, F <: AbstractVector{<:Function}}`: Constructs a `CombineLatentModels` instance with specified models and inverse link functions, ensuring that the number of models matches the number of inverse link functions and that there are at least two models.

# Examples

```julia
using EpiAware, Distributions
combined_model = CombineLatentModels([Intercept(Normal(2, 0.2)), AR()])
latent_model = generate_latent(combined_model, 10)
latent_model()
rand(latent_model)
```
"

struct CombineLatentModels{
    M <: AbstractVector{<:AbstractTuringLatentModel}, F <: AbstractVector{<:Function}} <:
       AbstractTuringLatentModel
    "A vector of latent models"
    models::M
    "The inverse link functions used to transform latent models when combining."
    inverse_links::F

    function CombineLatentModels(models::AbstractVector{<:AbstractTuringLatentModel};
            inverse_link::Function = x -> x)
        inverse_links = fill(inverse_link, length(models))
        return CombineLatentModels(models, inverse_links)
    end

    function CombineLatentModels(models::M,
            inverse_links::F) where {M <: AbstractVector{<:AbstractTuringLatentModel},
            F <: AbstractVector{<:Function}}
        @assert length(models)==length(inverse_links) "Number of models and links must be equal"
        @assert length(models)>1 "At least two models are required"
        return new{M, F}(models, inverse_links)
    end
end

@model function EpiAwareBase.generate_latent(latent_models::CombineLatentModels, n)
    latent_aux = Array{Any}(undef, length(latent_models.models))

    @submodel latent, latent_aux[1] = generate_latent(latent_models.models[1], n)
    transformed_latents = latent_models.inverse_links[1](latent)
    combined_latents = transformed_latents

    for i in 2:length(latent_models.models)
        @submodel latent, latent_aux[i] = generate_latent(latent_models.models[i], n)
        transformed_latents = latent_models.inverse_links[i](latent)
        combined_latents += transformed_latents
    end

    return combined_latents, (; latent_aux...)
end
