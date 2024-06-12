@doc raw"
The `ConcatLatentModels` struct.

This struct is used to concatenate multiple latent models into a single latent model.

# Constructors

- `ConcatLatentModels(models::M, no_models::Int, dimension_adaptor::Function) where {M <: AbstractVector{<:AbstractTuringLatentModel}}`: Constructs a `ConcatLatentModels` instance with specified models, number of models, and dimension adaptor.
- `ConcatLatentModels(models::M, dimension_adaptor::Function) where {M <: AbstractVector{<:AbstractTuringLatentModel}}`: Constructs a `ConcatLatentModels` instance with specified models and dimension adaptor, ensuring that there are at least two models. The default dimension adaptor is `equal_dimensions`.
- `ConcatLatentModels(; models::M, dimension_adaptor::Function) where {M <: AbstractVector{<:AbstractTuringLatentModel}}`: Constructs a `ConcatLatentModels` instance with specified models and dimension adaptor, ensuring that there are at least two models. The default dimension adaptor is `equal_dimensions`.

# Examples

```julia
using EpiAware, Distributions
combined_model = ConcatLatentModels([Intercept(Normal(2, 0.2)), AR()])
latent_model = generate_latent(combined_model, 10)
latent_model()
```
"
struct ConcatLatentModels{
    M <: AbstractVector{<:AbstractTuringLatentModel}, N <: Int, F <: Function} <:
       AbstractTuringLatentModel
    "A vector of latent models"
    models::M
    "The number of models in the collection"
    no_models::N
    "The dimension function for the latent variables. By default this divides the number of latent variables by the number of models and returns a vector of dimensions rounding up the first element and rounding down the rest."
    dimension_adaptor::F

    function ConcatLatentModels(models::M,
            no_models::I,
            dimension_adaptor::F) where {
            M <: AbstractVector{<:AbstractTuringLatentModel}, I <: Int,
            F <: Function}
        @assert length(models)>1 "At least two models are required"
        @assert length(models)==no_models "no_models must be equal to the number of models"
        # check all dimension functions take a single n and return an integer
        check_dim = dimension_adaptor(no_models, no_models)
        @assert typeof(check_dim)<:AbstractVector{Int} "Output of dimension_adaptor must be a vector of integers"
        @assert length(check_dim)==no_models "The vector of dimensions must have the same length as the number of models"
        return new{AbstractVector{<:AbstractTuringLatentModel}, Int, Function}(
            models, no_models, dimension_adaptor)
    end

    function ConcatLatentModels(models::M,
            dimension_adaptor::Function) where {
            M <: AbstractVector{<:AbstractTuringLatentModel}}
        return ConcatLatentModels(models, length(models), dimension_adaptor)
    end

    function ConcatLatentModels(models::M;
            dimension_adaptor::Function = equal_dimensions) where {
            M <: AbstractVector{<:AbstractTuringLatentModel}}
        return ConcatLatentModels(models, dimension_adaptor)
    end

    function ConcatLatentModels(; models::M,
            dimension_adaptor::Function = equal_dimensions) where {
            M <: AbstractVector{<:AbstractTuringLatentModel}}
        return ConcatLatentModels(models, dimension_adaptor)
    end
end

@doc raw"
Return a vector of dimensions that are equal or as close as possible, given the total number of elements `n` and the number of dimensions `m`. The default
dimension adaptor for `ConcatLatentModels`.

# Arguments
- `n::Int`: The total number of elements.
- `m::Int`: The number of dimensions.

# Returns
- `dims::AbstractVector{Int}`: A vector of dimensions, where the first element is the ceiling of `n / m` and the remaining elements are the floor of `n / m`.
"
function equal_dimensions(n::Int, m::Int)::AbstractVector{Int}
    return vcat(ceil(n / m), fill(floor(n / m), m - 1))
end

@doc raw"
Generate latent variables by concatenating multiple latent models.

# Arguments
- `latent_models::ConcatLatentModels`: An instance of the `ConcatLatentModels` type representing the collection of latent models.
- `n`: The number of latent variables to generate.

# Returns
- `concatenated_latents`: The combined latent variables generated from all the models.
- `latent_aux`: A tuple containing the auxiliary latent variables generated from each individual model.
"
@model function EpiAwareBase.generate_latent(latent_models::ConcatLatentModels, n)
    @assert latent_models.no_models<n "The number of latent variables must be greater than the number of models"
    dims = latent_models.dimension_adaptor(n, latent_models.no_models)

    @assert all(x -> x > 0, dims) "Non-positive dimensions are not allowed"
    @assert sum(dims)==n "Sum of dimensions must be equal to the dimension of the latent variables"

    @submodel final_latent, latent_aux = _concat_latents(
        latent_models.models, 1, [], [], dims, latent_models.no_models)

    return final_latent, (; latent_aux...)
end

@model function _concat_latents(
        models, index::Int, acc_latent, acc_aux, dims::AbstractVector{<:Int}, n_models::Int)
    if index > n_models
        return acc_latent, (; acc_aux...)
    else
        @submodel latent, new_aux = generate_latent(models[index], dims[index])
        @submodel updated_latent, updated_aux = _concat_latents(
            models, index + 1, vcat(acc_latent, latent),
            (; acc_aux..., new_aux...), dims, n_models)
        return updated_latent, (; updated_aux...)
    end
end
