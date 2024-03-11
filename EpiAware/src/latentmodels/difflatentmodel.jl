struct DiffLatentModel <: AbstractLatentModel
    model::AbstractModel
    init_prior::Priors
    d::Int

    function DiffLatentModel(model::AbstractModel, init_prior::Priors)
        d = length(init_prior)
        return DiffLatentModel(model, init_prior, d)
    end

    function DiffLatentModel(model::AbstractModel, init_prior::Priors, d::Int)
        @assert d>0 "d must be greater than 0"
        @assert length(init_prior)==d "Length of init_prior must be equal to d"
        return new(model, init_prior, d)
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
