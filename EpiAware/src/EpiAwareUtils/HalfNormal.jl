@doc raw"
Create a half-normal prior distribution with the specified mean.

# Arguments:

- `μ`: The mean of the half-normal distribution.

# Returns:

- A `HalfNormal` distribution with the specified mean.

# Examples:

```julia
using EpiAware
hn = HalfNormal(1.0)
rand(hn)
cdf(hn, 4)
quantile(hn, 0.5)
logpdf(hn, 2)
mean(hn)
var(hn)
entropy(hn)
```
"
struct HalfNormal{T <: Real} <: ContinuousUnivariateDistribution
    μ::T
end

function Base.rand(rng::AbstractRNG, d::HalfNormal{T}) where {T <: Real}
    abs(rand(rng, Normal(d.μ * sqrt(π / 2), d.μ / sqrt(2))))
end

# Log probability density function
function Distributions.logpdf(d::HalfNormal{T}, x::Real) where {T <: Real}
    x < 0 ? -Inf : logpdf(Normal(d.μ * sqrt(π / 2), d.μ / sqrt(2)), x) - log(2)
end

# Cumulative distribution function
function Distributions.cdf(d::HalfNormal{T}, x::Real) where {T <: Real}
    x < 0 ? 0.0 :
    cdf(Normal(d.μ * sqrt(π / 2), d.μ / sqrt(2)), x) -
    cdf(Normal(d.μ * sqrt(π / 2), d.μ / sqrt(2)), -x)
end

# Quantile function
function Distributions.quantile(d::HalfNormal{T}, q::Real) where {T <: Real}
    quantile(Normal(d.μ * sqrt(π / 2), d.μ / sqrt(2)), q + (1 - q) / 2)
end

# Support boundaries
Base.minimum(d::HalfNormal) = 0.0
Base.maximum(d::HalfNormal) = Inf
Distributions.insupport(d::HalfNormal, x::Real) = x >= 0

# Mean
Statistics.mean(d::HalfNormal{T}) where {T <: Real} = d.μ * sqrt(2 / π)

# Variance
Statistics.var(d::HalfNormal{T}) where {T <: Real} = d.μ^2 * (1 - 2 / π)

# Entropy
StatsBase.entropy(d::HalfNormal{T}) where {T <: Real} = log(2 * d.μ * sqrt(π / 2)) + 0.5

# Modes
StatsBase.modes(d::HalfNormal) = [0.0]
StatsBase.mode(d::HalfNormal) = 0.0

# Skewness
StatsBase.skewness(d::HalfNormal{T}) where {T <: Real} = (4 - π) * sqrt(2 / (π - 2))

# Kurtosis
StatsBase.kurtosis(d::HalfNormal, ::Bool) = 3 + (8 * (π - 3)) / (π - 2)

# Moment generating function
function Distributions.mgf(d::HalfNormal{T}, t::Real) where {T <: Real}
    exp(d.μ^2 * t^2 / 2) * (1 + erf(d.μ * t / sqrt(2))) / 2
end

# Characteristic function
function Distributions.cf(d::HalfNormal{T}, t::Real) where {T <: Real}
    exp(-d.μ^2 * t^2 / 4) * (1 + sqrt(2 / π) * d.μ * t * erfi(d.μ * t / sqrt(2)))
end
