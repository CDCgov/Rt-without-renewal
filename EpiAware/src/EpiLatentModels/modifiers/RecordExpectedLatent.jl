@doc raw"
   Record a variable (using the `Turing` `:=` syntax) in a latent model.

    # Fields
    - `model::AbstractTuringLatentModel`: The latent model to dispatch to.

    # Constructors

    - `RecordExpectedLatent(model::AbstractTuringLatentModel)`: Record the expected latent vector from the model as `exp_latent`.

    # Examples

    ```julia
    using EpiAware, Turing
    mdl = RecordExpectedLatent(FixedIntercept(0.1))
    gen_latent = generate_latent(mdl, 1)
    sample(gen_latent, Prior(), 10)
    ```
"
struct RecordExpectedLatent{M <: AbstractTuringLatentModel} <:
       AbstractTuringLatentModel
    model::M
end

@model function EpiAwareBase.generate_latent(model::RecordExpectedLatent, n)
    @submodel latent = generate_latent(model.model, n)
    exp_latent := latent
    return latent
end
