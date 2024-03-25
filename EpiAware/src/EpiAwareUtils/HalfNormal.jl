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
```
"
struct HalfNormal{T <: Real} <: ContinuousUnivariateDistribution
    μ::T
end

function Base.rand(rng::AbstractRNG, d::HalfNormal{T}) where {T <: Real}
    abs(rand(rng, Normal(0, d.μ * sqrt(π / 2))))
end

# Log probability density function
function Distributions.logpdf(d::HalfNormal{T}, x::Real) where {T <: Real}
    x < 0 ? -Inf : logpdf(Normal(0, d.μ * sqrt(π / 2)), x) - log(2)
end

# Cumulative distribution function
function Distributions.cdf(d::HalfNormal{T}, x::Real) where {T <: Real}
    x < 0 ? 0.0 :
    cdf(Normal(0, d.μ * sqrt(π / 2)), x) -
    cdf(Normal(0, d.μ * sqrt(π / 2)), -x)
end

# Quantile function
function Distributions.quantile(d::HalfNormal{T}, q::Real) where {T <: Real}
    quantile(Normal(0, d.μ * sqrt(π / 2)), q + (1 - q) / 2)
end

# Support boundaries
Base.minimum(d::HalfNormal) = 0.0
Base.maximum(d::HalfNormal) = Inf
Distributions.insupport(d::HalfNormal, x::Real) = x >= 0

# Mean
Statistics.mean(d::HalfNormal{T}) where {T <: Real} = d.μ

# Variance
Statistics.var(d::HalfNormal{T}) where {T <: Real} = d.μ^2 * (1 - 2 / π)

# Modes
StatsBase.modes(d::HalfNormal) = [0.0]
StatsBase.mode(d::HalfNormal) = 0.0
