"""
The `DiffLatentModel` struct represents a differential latent model that is a subtype of `AbstractLatentModel`.

## Fields
- `model::M`: The underlying latent model.
- `init_prior::P`: The initial priors for the latent variables.
- `d::Int`: The dimensionality of the latent variables.

## Constructors
- `DiffLatentModel(;latentmodel, init_priors::Vector{<:Distribution})`: Constructs a `DiffLatentModel` object with the given latent model and initial priors.
- `DiffLatentModel(;latentmodel, init_prior_distribution::Distribution, d::Int)`: Constructs a `DiffLatentModel` object with the given latent model, initial prior distribution, and dimensionality.

"""
struct DiffLatentModel{M, P} <: AbstractLatentModel
    "Underlying latent model for the differenced process"
    model::M
    "The prior distribution for the initial latent variables."
    init_prior::P
    "Number of times differenced."
    d::Int

    function DiffLatentModel(latentmodel; init_prior_distribution::Distribution, d::Int)
        init_priors = fill(init_prior_distribution, d)
        return DiffLatentModel(; latentmodel = latentmodel, init_priors = init_priors)
    end

    function DiffLatentModel(;
            latentmodel, init_priors::Vector{D} where {D <: Distribution})
        d = length(init_priors)
        init_prior = all(first(init_priors) .== init_priors) ?
                     filldist(first(init_priors), d) : arraydist(init_priors)
        return new{typeof(latentmodel), typeof(init_prior)}(latentmodel, init_prior, d)
    end
end

function default_diff_latent_priors(d::Int)
    return (init_prior = [Normal(0.0, 1.0) for i in 1:d],)
end

@model function generate_latent(latent_model::DiffLatentModel, n)
    d = latent_model.d
    @assert n>d "n must be longer than d"
    latent_init ~ latent_model.init_prior

    @submodel diff_latent, diff_latent_aux = generate_latent(latent_model.model, n - d)

    return _combine_diff(latent_init, diff_latent, d), (; latent_init, diff_latent_aux...)
end

function _combine_diff(init, diff, d)
    combined = vcat(init, diff)

    for i in 1:d
        combined = cumsum(combined)
    end

    return combined
end
