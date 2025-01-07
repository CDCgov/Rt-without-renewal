@doc raw"
The `BinomialError` struct represents an observation model for
binomial errors. It is a subtype of `AbstractTuringObservationErrorModel`,
which incorporates the number of trials `N` (default 1000) and models the number of successes `y_t`. Unlike the `NegativeBinomialError` model,
the `BinomialError` model does not require `Y_t` to be an expected count
but instead a probability of success. It also requires that `y_t` is a named tuple with `N` and `y_t` as fields. Where `N` is the number of trials
and `y_t` is the number of successes.

## Constructors
- `BinomialError(N::Integer)`: Constructs a `BinomialError` object with default values for `N` and `y_t`.
- `BinomialError(; N::Integer = 1000)`: Constructs a `BinomialError` object, allowing the user to set the number
    of trials if no `y_t` is provided.

## Examples
```julia
using EpiAware

# Create a BinomialError model with default number of trials
bin = BinomialError()

# Create a BinomialError model with custom number of trials
bin_custom = BinomialError(20)

# Define observation data with number of trials and the number of successes
y_data = (N = fill(10, 10), y_t = fill(3.0, 10))

# Generate observations using the BinomialError model
bin_model = generate_observations(bin, y_data, fill(0.5, 10))

# Sample from the generated model
sample = rand(bin_model)
```
"
@kwdef struct BinomialError{I <: Integer} <: AbstractTuringObservationErrorModel
    "The number of trials for the binomial distribution."
    N::I = 1000
end

@doc raw"
Defines `y_t` when it is `missing` for `BinomialError`.
Constructs a NamedTuple with `N` from the model `obs_model` and `y_t` as a vector of `Missing` values.
"
function define_y_t(
            obs_model::BinomialError, y_t, Y_t)
    if ismissing(y_t)
        y_t = Vector{Missing}(missing, length(Y_t))
    else
        y_t = y_t.y_t
    end
    return y_t
end

@doc raw"
Generates priors for the `BinomialError` model. Extracts `N` from `y_t` when it is a NamedTuple.
"
@model function generate_observation_error_priors(obs_model::BinomialError, y_t, Y_t)
    if ismissing(y_t)
        N = fill(obs_model.N, length(Y_t))
    else
        N = y_t.N
    end
    return (N = N,)
end

@doc raw"
This function generates the observation error model based on the binomial error model. It dispatches to the `Binomial` distribution using the number of trials `N` and the probability of success `p`.
"
function observation_error(obs_model::BinomialError, Y_t, N)
    return Binomial(N, Y_t)
end
