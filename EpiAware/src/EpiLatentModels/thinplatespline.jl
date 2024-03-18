@doc raw"
The thin plate spline (ThinPlateSpline) model struct.

# Fields
- `λ_prior`: Prior distribution for the smoothing parameter λ.
- `σ_prior`: Prior distribution for the observation noise standard deviation σ.
- `M`: Number of polynomial terms.

# Constructors
- `ThinPlateSpline(λ_prior, σ_prior, M)`: Constructs a ThinPlateSpline model with the specified priors and number of polynomial terms.
- `ThinPlateSpline(; λ_prior=Gamma(1.0, 1.0), σ_prior=HalfNormal(0.1), M=3)`: Constructs a ThinPlateSpline model with default priors and number of polynomial terms.

# Examples
```julia
using Distributions
using EpiAware
tps = ThinPlateSpline()
tps_model = generate_latent(tps, 10)
rand(tps_model)
```
"
struct ThinPlateSpline{L <: Sampleable, S <: Sampleable, M <: Int}
    λ_prior::L
    σ_prior::S
    M::M

    function ThinPlateSpline(; λ_prior::Sampleable = Gamma(1.0, 1.0),
            σ_prior::Sampleable = HalfNormal(0.1), M::Int = 3)
        ThinPlateSpline(λ_prior, σ_prior, M)
    end

    function ThinPlateSpline(λ_prior::Sampleable, σ_prior::Sampleable, M::Int)
        @assert M>=1 "M must be a positive integer"
        new{typeof(λ_prior), typeof(σ_prior), typeof(M)}(λ_prior, σ_prior, M)
    end
end

@doc raw"
Generate a latent thin plate spline surface.

# Arguments
- `latent_model::ThinPlateSpline`: The ThinPlateSpline model.
- `t::Vector{Float64}`: The vector of time points.

# Returns
- `f::Vector{Float64}`: The generated TPS surface values at the time points.
- `params::NamedTuple`: A named tuple containing the generated parameters (`λ`, `σ`, `w`, `a`).

# Notes
- `t` should be a vector of length T, where T is the number of time points.
"
@model function EpiAwareBase.generate_latent(latent_model::ThinPlateSpline, t)
    T = length(t)
    M = latent_model.M

    # Input locations
    x = [t t .^ 2]  # Construct x from t (assuming 1D input)
    N, D = size(x)

    # Polynomial coefficients
    a ~ MvNormal(zeros(M), 1000 * I)

    # Spline coefficients
    λ ~ latent_model.λ_prior
    S = _thin_plate_spline_penalty(x, Val(D), Val(M))
    w ~ MvNormal(zeros(N), λ * Symmetric(inv(S)))

    # Observation model
    σ ~ latent_model.σ_prior
    f = _thin_plate_spline(x, [a; w], Val(D), Val(M))
    y ~ MvNormal(f, σ^2 * I)

    return f, (; λ, σ, w, a)
end

"""
Calculate the thin plate spline penalty matrix for a D-dimensional spline with M covariates.

# Arguments
- `x`: N x D matrix of input locations
- `D`: Dimensionality of covariate space (type parameter)
- `M`: Number of covariates (type parameter)

# Returns
- `N x N` penalty matrix
"""
function _thin_plate_spline_penalty(x, ::Val{D}, ::Val{M}) where {D, M}
    N = size(x, 1)
    S = zeros(N, N)
    for i in 1:N
        for j in 1:N
            r2 = sum(abs2, x[i, :] .- x[j, :])
            S[i, j] = r2 == 0 ? 0.0 : r2 * log(r2)
        end
    end
    return S
end

"""
Evaluate a D-dimensional thin plate spline with M covariates at locations x
with coefficients z.

# Arguments
- `x`: N x D matrix of evaluation locations
- `z`: K x 1 vector of spline coefficients
- `D`: Dimensionality of covariate space (type parameter)
- `M`: Number of covariates (type parameter)

# Returns
- `N x 1` vector of spline evaluations at each location in `x`
"""
function _thin_plate_spline(x, z, ::Val{D}, ::Val{M}) where {D, M}
    N = size(x, 1)
    K = size(z, 1)
    Φ = zeros(N, K)
    # Polynomial terms
    for i in 1:M
        Φ[:, i] .= x[:, i]
    end
    # Radial basis functions
    for i in 1:N
        for k in 1:(K - M)
            r2 = sum(abs2, x[i, :] .- x[k, :])
            Φ[i, M + k] = r2 == 0 ? 0.0 : r2 * log(r2)
        end
    end
    return Φ * z
end
