@doc raw"

The `NegativeBinomialError` struct represents an observation model for negative binomial errors. It is a subtype of `AbstractTuringObservationModel`.

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
       AbstractTuringObservationErrorModel
    "The prior distribution for the cluster factor."
    cluster_factor_prior::S
    "The positive shift value."
    pos_shift::T

    function NegativeBinomialError(;
            cluster_factor_prior::Distribution = HalfNormal(0.01),
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
Generates observation error priors based on the `NegativeBinomialError` observation model. This function generates the cluster factor prior for the negative binomial error model.
"
@model function generate_observation_error_priors(
        obs_model::NegativeBinomialError, Y_t, y_t)
    cluster_factor ~ obs_model.cluster_factor_prior
    sq_cluster_factor = cluster_factor^2
    return (; sq_cluster_factor)
end

@doc raw"
This function generates the observation error model based on the negative binomial error model with a positive shift. It dispatches to the `NegativeBinomialMeanClust` distribution.
"
function observation_error(obs_model::NegativeBinomialError, Y_t, sq_cluster_factor)
    return NegativeBinomialMeanClust(Y_t + obs_model.pos_shift,
        sq_cluster_factor)
end
