@doc raw"
Create a half-normal prior distribution with the specified mean.

# Arguments:

- `μ`: The mean of the half-normal distribution.

# Returns:

- A `HalfNormal` distribution with the specified mean.

# Examples:

```jldoctest HalfNormal
using EpiAware, Distributions

hn = HalfNormal(1.0)
# output
EpiAware.EpiAwareUtils.HalfNormal{Float64}(μ=1.0)
```

# filter out all the values that are less than 0
```jldoctest HalfNormal; filter = r\"\b\d+(\.\d+)?\b\" => \"*\"
rand(hn)
# output
0.4508533245229199
```

```jldoctest HalfNormal
cdf(hn, 2)
# output
0.8894596502772643
```

```jldoctest HalfNormal
quantile(hn, 0.5)
# output
0.8453475393951495
```

```jldoctest HalfNormal
logpdf(hn, 2)
# output
-3.1111166111445083
```

```jldoctest HalfNormal
mean(hn)
# output
1.0
```

```jldoctest HalfNormal
var(hn)
# output
0.5707963267948966
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
Statistics.var(d::HalfNormal{T}) where {T <: Real} = d.μ^2 * (π / 2 - 1)
