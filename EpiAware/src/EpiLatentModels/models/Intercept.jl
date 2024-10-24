@doc raw"
The `Intercept` struct is used to model the intercept of a latent process. It
broadcasts a single intercept value to a length `n` latent process.

## Constructors

- Intercept(intercept_prior)
- Intercept(; intercept_prior)

## Examples

```jldoctest Intercept
using Distributions, Turing, EpiAware
int = Intercept(Normal(0, 1))
int
# output
Intercept{Normal{Float64}}(intercept_prior=Normal{Float64}(μ=0.0, σ=1.0))
```

```jldoctest Intercept; filter=r\"\b\d+(\.\d+)?\b\" => \"*\"
mdl = generate_latent(int, 10)
mdl()
# output
```

```jldoctest Intercept; filter=r\"\b\d+(\.\d+)?\b\" => \"*\"
rand(mdl)
# output
```
"
@kwdef struct Intercept{D <: Sampleable} <: AbstractTuringIntercept
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
    return fill(intercept, n)
end

@doc raw"
A variant of the `Intercept` struct that represents a fixed intercept value for a latent model.

# Constructors

- `FixedIntercept(intercept)` : Constructs a `FixedIntercept` instance with the specified intercept value.
- `FixedIntercept(; intercept)` : Constructs a `FixedIntercept` instance with the specified intercept value using named arguments.

# Examples

```julia
using EpiAware
fi = FixedIntercept(2.0)
fi_model = generate_latent(fi, 10)
fi_model()
```
"
@kwdef struct FixedIntercept{F <: Real} <: AbstractTuringIntercept
    intercept::F
end

@doc raw"

Generate a latent intercept series with a fixed intercept value.

# Arguments
- `latent_model::FixedIntercept`: The fixed intercept latent model.
- `n`: The number of latent variables to generate.

# Returns
- `latent_vars`: An array of length `n` filled with the fixed intercept value.
"
@model function EpiAwareBase.generate_latent(latent_model::FixedIntercept, n)
    return fill(latent_model.intercept, n)
end
