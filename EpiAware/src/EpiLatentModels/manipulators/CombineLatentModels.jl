@doc raw"
The `CombineLatentModels` struct.

This struct is used to combine multiple latent models into a single latent model. If a prefix is supplied wraps each model with `PrefixLatentModel`.

# Constructors
- `CombineLatentModels(models::M, prefixes::P) where {M <: AbstractVector{<:AbstractTuringLatentModel}, P <: AbstractVector{<:String}}`: Constructs a `CombineLatentModels` instance with specified models and prefixes, ensuring that there are at least two models and the number of models and prefixes are equal.
- `CombineLatentModels(models::M) where {M <: AbstractVector{<:AbstractTuringLatentModel}}`: Constructs a `CombineLatentModels` instance with specified models, automatically generating prefixes for each model. The
automatic prefixes are of the form `Combine.1`, `Combine.2`, etc.

# Examples

```julia
using EpiAware, Distributions
combined_model = CombineLatentModels([Intercept(Normal(2, 0.2)), AR()])
latent_model = generate_latent(combined_model, 10)
latent_model()
```
"
@kwdef struct CombineLatentModels{
    M <: AbstractVector{<:AbstractTuringLatentModel}, P <: AbstractVector{<:String}} <:
              AbstractTuringLatentModel
    "A vector of latent models"
    models::M
    "A vector of prefixes for the latent models"
    prefixes::P

    function CombineLatentModels(models::M,
            prefixes::P) where {
            M <: AbstractVector{<:AbstractTuringLatentModel},
            P <: AbstractVector{<:String}}
        @assert length(models)>1 "At least two models are required"
        @assert length(models)==length(prefixes) "The number of models and prefixes must be equal"
        prefix_models = [prefixes[i] == "" ? models[i] :
                         PrefixLatentModel(models[i], prefixes[i])
                         for i in eachindex(models)]
        return new{AbstractVector{<:AbstractTuringLatentModel}, AbstractVector{<:String}}(
            prefix_models, prefixes)
    end
end

function CombineLatentModels(models::M) where {
        M <: AbstractVector{<:AbstractTuringLatentModel}}
    prefixes = "Combine." .* string.(1:length(models))
    return CombineLatentModels(models, prefixes)
end

@doc raw"
Generate latent variables using a combination of multiple latent models.

# Arguments
- `latent_models::CombineLatentModels`: An instance of the `CombineLatentModels` type representing the collection of latent models.
- `n`: The number of latent variables to generate.

# Returns
- The combined latent variables generated from all the models.

# Example
"
@model function EpiAwareBase.generate_latent(latent_models::CombineLatentModels, n)
    @submodel final_latent = _accumulate_latents(
        latent_models.models, 1, fill(0.0, n), n, length(latent_models.models))

    return final_latent
end

@model function _accumulate_latents(
        models, index, acc_latent, n, n_models)
    if index > n_models
        return acc_latent
    else
        @submodel latent = generate_latent(models[index], n)
        @submodel updated_latent = _accumulate_latents(
            models, index + 1, acc_latent .+ latent, n, n_models)
        return updated_latent
    end
end
