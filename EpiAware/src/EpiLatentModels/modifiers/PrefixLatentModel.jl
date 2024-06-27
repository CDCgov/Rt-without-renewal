@doc raw"
    Generate a latent model with a prefix. A lightweight wrapper around `EpiAwareUtils.prefix_submodel`.

    # Constructors
    - `PrefixLatentModel(model::M, prefix::P)`: Create a `PrefixLatentModel` with the latent model `model` and the prefix `prefix`.
    - `PrefixLatentModel(; model::M, prefix::P)`: Create a `PrefixLatentModel` with the latent model `model` and the prefix `prefix`.

    # Examples
    ```julia
    using EpiAware
    latent_model = PrefixLatentModel(model = HierarchicalNormal(), prefix = \"Test\")
    mdl = generate_latent(latent_model, 10)
    rand(mdl)
    ```
"
@kwdef struct PrefixLatentModel{M <: AbstractTuringLatentModel, P <: String} <:
              AbstractTuringLatentModel
    "The latent model"
    model::M
    "The prefix for the latent model"
    prefix::P
end

@model function EpiAwareBase.generate_latent(latent_model::PrefixLatentModel, n)
    @submodel submodel = prefix_submodel(
        latent_model.model, generate_latent, latent_model.prefix, n)
    return submodel
end
