@doc raw"
The `Intercept` struct is used to model the intercept of a latent process. It
broadcasts a single intercept value to a length `n` latent process.

## Constructors

- Intercept(intercept_prior)
- Intercept(; intercept_prior)

## Examples

```julia
using Distributions, Turing, EpiAware
int = Intercept(Normal(0, 1))
int_model = generate_latent(int, 10)
rand(int_model)
int_model()
```
"
struct Intercept{D <: Sampleable} <: AbstractTuringLatentModel
    "Prior distribution for the intercept."
    intercept_prior::D
end

@doc raw"
Generate a latent intercept series.

# Arguments

- `latent_model::Intercept`: The intercept model.
- `n::Int`: The length of the intercept series.

# Returns

- `intercept::Vector{Float64}`: The generated intercept series.
"
@model function EpiAwareBase.generate_latent(latent_model::Intercept, n)
    intercept ~ latent_model.intercept_prior
    return fill(intercept, n), (; intercept = intercept)
end
