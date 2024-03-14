
@doc raw"""
Model the latent process as a `d`-fold differenced version of another process.

## Mathematical specification

Let ``\Delta`` be the differencing operator. If ``\tilde{Z}_t`` is a realisation of
undifferenced latent model supplied to `DiffLatentModel`, then the differenced process is
given by,

```math
\Delta^{(d)} Z_t = \tilde{Z}_t, \quad t = d+1, \ldots.
```

We can recover ``Z_t`` by applying the inverse differencing operator ``\Delta^{-1}``, which
corresponds to the cumulative sum operator `cumsum` in Julia, `d`-times. The `d` initial
terms ``Z_1, \ldots, Z_d`` are inferred.

## Constructors

- `DiffLatentModel(latentmodel, init_prior_distribution::Distribution; d::Int)`
    Constructs a `DiffLatentModel` for `d`-fold differencing with `latentmodel` as the
    undifferenced latent process. All initial terms have common prior
    `init_prior_distribution`.
- `DiffLatentModel(;undiffmodel, init_priors::Vector{D} where {D <: Distribution})`
    Constructs a `DiffLatentModel` for `d`-fold differencing with `latentmodel` as the
    undifferenced latent process. The `d` initial terms have priors given by the vector
    `init_priors`, therefore `length(init_priors)` sets `d`.

## Example usage with `generate_latent`

`generate_latent` can be used to construct a `Turing` model for the differenced latent
process. In this example, the underlying undifferenced process is a `RandomWalk` model.


First, we construct a `RandomWalk` struct with an initial value prior and a step size
standard deviation prior.

```julia
using Distributions, EpiAware
rw = RandomWalk(Normal(0.0, 1.0), truncated(Normal(0.0, 0.05), 0.0, Inf))
```

Then, we can use `DiffLatentModel` to construct a `DiffLatentModel` for `d`-fold
differenced process with `rw` as the undifferenced latent process.

We have two constructor options for `DiffLatentModel`. The first option is to supply a
common prior distribution for the initial terms and specify `d` as follows:

```julia
diff_model = DiffLatentModel(rw, Normal(); d = 2)
```

Or we can supply a vector of priors for the initial terms and `d` is inferred as follows:
```julia
diff_model2 = DiffLatentModel(;undiffmodel = rw, init_priors = [Normal(), Normal()])
```

Then, we can use `generate_latent` to construct a Turing model for the differenced latent
process generating a length `n` process,

```julia
# Construct a Turing model
n = 100
difference_mdl = generate_latent(diff_model, n)
```

Now we can use the `Turing` PPL API to sample underlying parameters and generate the
unobserved latent process.

```julia
#Sample random parameters from prior
θ = rand(difference_mdl)
#Get a sampled latent process as a generated quantity from the model
Z_t = generated_quantities(difference_mdl, θ)
```

"""
struct DiffLatentModel{M <: AbstractLatentModel, P} <: AbstractLatentModel
    "Underlying latent model for the differenced process"
    model::M
    "The prior distribution for the initial latent variables."
    init_prior::P
    "Number of times differenced."
    d::Int

    function DiffLatentModel(
            undiffmodel::AbstractLatentModel, init_prior_distribution::Distribution; d::Int)
        init_priors = fill(init_prior_distribution, d)
        return DiffLatentModel(; undiffmodel = undiffmodel, init_priors = init_priors)
    end

    function DiffLatentModel(; undiffmodel::AbstractLatentModel,
            init_priors::Vector{D} where {D <: Distribution})
        d = length(init_priors)
        init_prior = all(first(init_priors) .== init_priors) ?
                     filldist(first(init_priors), d) : arraydist(init_priors)
        return new{typeof(undiffmodel), typeof(init_prior)}(undiffmodel, init_prior, d)
    end
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
