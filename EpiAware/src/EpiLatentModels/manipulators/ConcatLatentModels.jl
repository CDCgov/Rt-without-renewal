@doc raw"
The `ConcatLatentModels` struct.

This struct is used to concatenate multiple latent models into a single latent model.

# Constructors

- `ConcatLatentModels(models::M, no_models::I, dimension_adaptor::F, prefixes::P) where {M <: AbstractVector{<:AbstractTuringLatentModel}, I <: Int, F <: Function, P <: AbstractVector{String}}`: Constructs a `ConcatLatentModels` instance with specified models, number of models, dimension adaptor, and prefixes.
- `ConcatLatentModels(models::M, dimension_adaptor::F; prefixes::P = \"Concat.\" * string.(1:length(models))) where {M <: AbstractVector{<:AbstractTuringLatentModel}, F <: Function}`: Constructs a `ConcatLatentModels` instance with specified models and dimension adaptor. The number of models is automatically determined as are the prefixes (of the form `Concat.1`, `Concat.2`, etc.) by default.
- `ConcatLatentModels(models::M; dimension_adaptor::Function, prefixes::P) where {M <: AbstractVector{<:AbstractTuringLatentModel}, P <: AbstractVector{String}}`: Constructs a `ConcatLatentModels` instance with specified models, dimension adaptor, prefixes, and automatically determines the number of models.The default dimension adaptor is `equal_dimensions`. The default prefixes are of the form `Concat.1`, `Concat.2`, etc.
- `ConcatLatentModels(; models::M, dimension_adaptor::Function, prefixes::P) where {M <: AbstractVector{<:AbstractTuringLatentModel}, P <: AbstractVector{String}}`: Constructs a `ConcatLatentModels` instance with specified models, dimension adaptor, prefixes, and automatically determines the number of models. The default dimension adaptor is `equal_dimensions`. The default prefixes are of the form `Concat.1`, `Concat.2`, etc.

# Examples

```julia
using EpiAware, Distributions
combined_model = ConcatLatentModels([Intercept(Normal(2, 0.2)), AR()])
latent_model = generate_latent(combined_model, 10)
latent_model()
```
"
struct ConcatLatentModels{
    M <: AbstractVector{<:AbstractTuringLatentModel}, N <: Int, F <: Function, P <:
                                                                               AbstractVector{<:String}} <:
       AbstractTuringLatentModel
    "A vector of latent models"
    models::M
    "The number of models in the collection"
    no_models::N
    "The dimension function for the latent variables. By default this divides the number of latent variables by the number of models and returns a vector of dimensions rounding up the first element and rounding down the rest."
    dimension_adaptor::F
    "A vector of prefixes for the latent models"
    prefixes::P

    function ConcatLatentModels(models::M,
            no_models::I,
            dimension_adaptor::F, prefixes::P) where {
            M <: AbstractVector{<:AbstractTuringLatentModel}, I <: Int,
            F <: Function, P <: AbstractVector{<:String}}
        @assert length(models)>1 "At least two models are required"
        @assert length(models)==no_models "no_models must be equal to the number of models"
        # check all dimension functions take a single n and return an integer
        check_dim = dimension_adaptor(no_models, no_models)
        @assert typeof(check_dim)<:AbstractVector{Int} "Output of dimension_adaptor must be a vector of integers"
        @assert length(check_dim)==no_models "The vector of dimensions must have the same length as the number of models"
        @assert length(prefixes)==no_models "The number of models and prefixes must be equal"
        prefix_models = [prefixes[i] == "" ? models[i] :
                         PrefixLatentModel(models[i], prefixes[i])
                         for i in eachindex(models)]
        return new{
            AbstractVector{<:AbstractTuringLatentModel}, Int, Function,
            AbstractVector{<:String}}(
            prefix_models, no_models, dimension_adaptor, prefixes)
    end
end

function ConcatLatentModels(models::M, dimension_adaptor::Function;
        prefixes = nothing) where {
        M <: AbstractVector{<:AbstractTuringLatentModel}}
    no_models = length(models)
    if isnothing(prefixes)
        prefixes = "Concat." .* string.(1:no_models)
    end
    return ConcatLatentModels(models, no_models, dimension_adaptor, prefixes)
end

function ConcatLatentModels(models::M;
        dimension_adaptor::Function = equal_dimensions,
        prefixes = nothing) where {
        M <: AbstractVector{<:AbstractTuringLatentModel}}
    return ConcatLatentModels(models, dimension_adaptor; prefixes = prefixes)
end

function ConcatLatentModels(; models::M,
        dimension_adaptor::Function = equal_dimensions, prefixes = nothing) where {
        M <: AbstractVector{<:AbstractTuringLatentModel}}
    return ConcatLatentModels(models, dimension_adaptor; prefixes = prefixes)
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

    @submodel final_latent = _concat_latents(
        latent_models.models, 1, nothing, dims, latent_models.no_models)

    return final_latent
end

@model function _concat_latents(
        models, index::Int, acc_latent, dims::AbstractVector{<:Int}, n_models::Int)
    if index > n_models
        return acc_latent
    else
        @submodel latent = generate_latent(models[index], dims[index])

        acc_latent = isnothing(acc_latent) ? latent : vcat(acc_latent, latent)
        @submodel updated_latent = _concat_latents(
            models, index + 1, acc_latent, dims, n_models
        )
        return updated_latent
    end
end
