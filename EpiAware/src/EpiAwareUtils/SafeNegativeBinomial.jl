@doc raw"
Create a Negative binomial distribution with the specified mean that avoids `InExactError`
when the mean is too large.


# Parameterisation:
We are using a mean and cluster factorization of the negative binomial distribution such
that the variance to mean relationship is:

```math
\sigma^2  = \mu + \alpha^2 \mu^2
```

The reason for this parameterisation is that at sufficiently large mean values (i.e. `μ > 1 / α`) `α` is approximately equal to the
standard fluctuation of the distribution, e.g. if `α = 0.05` we expect typical fluctuations of samples from the negative binomial to be
about 5% of the mean when the mean is notably larger than 20. Otherwise, we expect approximately Poisson noise. In our opinion, this
parameterisation is useful for specifying the distribution in a way that is easier to reason on priors for `α`.

# Arguments:

- `μ`: The mean of the Negative binomial distribution.
- `α`: The cluster factor of the Negative binomial distribution.

# Returns:

- A `SafeNegativeBinomial` distribution with the specified mean.

# Examples:

```jldoctest SafeNegativeBinomial
using EpiAware, Distributions

bigλ = exp(48.0) #Large value of λ
α = 0.05
d = SafeNegativeBinomial(bigλ, α)
# output
EpiAware.EpiAwareUtils.SafeNegativeBinomial{Float64}(μ=7.016735912097631e20, α=0.05)
```

```jldoctest SafeNegativeBinomial
cdf(d, 2)
# output
0.0
```

```jldoctest SafeNegativeBinomial
logpdf(d, 100)
# output
-16556.546939786767
```

```jldoctest SafeNegativeBinomial
mean(d)
# output
7.016735912097631e20
```

```jldoctest SafeNegativeBinomial
var(d)
# output
1.2308645715030148e39
```
"
struct SafeNegativeBinomial{T<:Real} <: DiscreteUnivariateDistribution
    μ::T
    α::T

    function SafeNegativeBinomial{T}(μ::T, α::T) where {T <: Real}
        return new{T}(μ, α)
    end
    SafeNegativeBinomial(μ::Real, α::Real) = SafeNegativeBinomial{eltype(μ)}(μ, α)
end

# helper function
function _negbin(d::SafeNegativeBinomial)
    μ² = d.μ^2
    ex_σ² = d.α^2 * μ²
    p = d.μ / (d.μ + ex_σ²)
    r = μ² / ex_σ²
    return NegativeBinomial(r, p)
end

### Support

Base.minimum(d::SafeNegativeBinomial) = 0
Base.maximum(d::SafeNegativeBinomial) = Inf
Distributions.insupport(d::SafeNegativeBinomial, x::Integer) = x >= 0


#### Parameters

Distributions.params(d::SafeNegativeBinomial) = _negbin(d) |> params
Distributions.partype(::SafeNegativeBinomial{T}) where {T} = T

Distributions.succprob(d::SafeNegativeBinomial) = _negbin(d).p
Distributions.failprob(d::SafeNegativeBinomial{T}) where {T} = one(T) - _negbin(d).p

#### Statistics

Distributions.mean(d::SafeNegativeBinomial) = d.μ
Distributions.var(d::SafeNegativeBinomial) = d.μ + d.α^2 * d.μ^2
Distributions.std(d::SafeNegativeBinomial) = sqrt(var(d))
Distributions.skewness(d::SafeNegativeBinomial) = _negbin(d) |> skewness
Distributions.kurtosis(d::SafeNegativeBinomial) = _negbin(d) |> kurtosis
Distributions.mode(d::SafeNegativeBinomial) = _negbin(d) |> mode
Distributions.kldivergence(p::SafeNegativeBinomial, q::SafeNegativeBinomial) = kldivergence(_negbin(p), _negbin(q))

#### Evaluation & Sampling

Distributions.logpdf(d::SafeNegativeBinomial, k::Real) = logpdf(_negbin(d), k)

Distributions.cdf(d::SafeNegativeBinomial, x::Real) = cdf(_negbin(d), x)
Distributions.ccdf(d::SafeNegativeBinomial, x::Real) = ccdf(_negbin(d), x)
Distributions.logcdf(d::SafeNegativeBinomial, x::Real) = logcdf(_negbin(d), x)
Distributions.logccdf(d::SafeNegativeBinomial, x::Real) = logccdf(_negbin(d), x)
Distributions.quantile(d::SafeNegativeBinomial, q::Real) = quantile(_negbin(d), q)
Distributions.cquantile(d::SafeNegativeBinomial, q::Real) = cquantile(_negbin(d), q)
Distributions.invlogcdf(d::SafeNegativeBinomial, lq::Real) = invlogcdf(_negbin(d), lq)
Distributions.invlogccdf(d::SafeNegativeBinomial, lq::Real) = invlogccdf(_negbin(d), lq)

## sampling
function Base.rand(rng::AbstractRNG, d::SafeNegativeBinomial)
    _d = _negbin(d)
    if isone(_d.p)
        return 0
    else
        return rand(rng, SafePoisson(rand(rng, Gamma(_d.r, (1 - _d.p)/_d.p))))
    end
end

Distributions.mgf(d::SafeNegativeBinomial, t::Real) = mgf(_negbin(d), t)
Distributions.cgf(d::SafeNegativeBinomial, t) = cgf(_negbin(d), t)
Distributions.cf(d::SafeNegativeBinomial, t::Real) = cf(_negbin(d), t)
