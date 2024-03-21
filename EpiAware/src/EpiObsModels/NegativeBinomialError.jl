@doc raw"

The `NegativeBinomialError` struct represents an observation model for negative binomial errors. It is a subtype of `AbstractObservationModel`.

## Constructors
- `NegativeBinomialError(; cluster_factor_prior::Distribution = HalfNormal(0.1), pos_shift::AbstractFloat = 1e-6)`: Constructs a `NegativeBinomialError` object with default values for the cluster factor prior and positive shift.
- `NegativeBinomialError(cluster_factor_prior::Distribution; pos_shift::AbstractFloat = 1e-6)`: Constructs a `NegativeBinomialError` object with a specified cluster factor prior and default value for the positive shift.

## Examples
```julia
using Distributions, Turing, EpiAware
nb = NegativeBinomialError()
nb_model = generate_observations(nb, missing, fill(10, 10))
rand(nb_model)
```
"
struct NegativeBinomialError{S <: Sampleable, T <: AbstractFloat} <:
       AbstractObservationModel
    "The prior distribution for the cluster factor."
    cluster_factor_prior::S
    "The positive shift value."
    pos_shift::T

    function NegativeBinomialError(;
            cluster_factor_prior::Distribution = HalfNormal(0.1),
            pos_shift::AbstractFloat = 1e-6)
        new{typeof(cluster_factor_prior), typeof(pos_shift)}(
            cluster_factor_prior, pos_shift)
    end

    function NegativeBinomialError(cluster_factor_prior::Distribution;
            pos_shift::AbstractFloat = 1e-6)
        new{typeof(cluster_factor_prior), typeof(pos_shift)}(
            cluster_factor_prior, pos_shift)
    end
end

@doc raw"
Generate observations using the NegativeBinomialError observation model.

# Arguments
- `obs_model::NegativeBinomialError`: The observation model.
- `y_t`: The observed values.
- `Y_t`: The true values.

# Returns
- `y_t`: The generated observations.
- `(; cluster_factor,)`: A named tuple containing the generated `cluster_factor`.
"
@model function EpiAwareBase.generate_observations(obs_model::NegativeBinomialError,
        y_t,
        Y_t)
    cluster_factor ~ obs_model.cluster_factor_prior
    sq_cluster_factor = cluster_factor^2
    if ismissing(y_t)
        y_t = Vector{Int}(undef, length(Y_t))
    end

    for i in eachindex(y_t)
        y_t[i] ~ NegativeBinomialMeanClust(
            Y_t[i] + obs_model.pos_shift, sq_cluster_factor
        )
    end

    return y_t, (; cluster_factor,)
end
