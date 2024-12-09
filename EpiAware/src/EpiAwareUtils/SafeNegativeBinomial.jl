@doc raw"
Create a Negative binomial distribution with the specified mean that avoids `InExactError`
when the mean is too large.


# Parameterisation:
We are using a mean and cluster factorization of the negative binomial distribution such
that the variance to mean relationship is:

```math
\sigma^2  = \mu + \alpha^2 \mu^2
```

The reason for this parameterisation is that at sufficiently large mean values (i.e. `r > 1 / p`) `p` is approximately equal to the
standard fluctuation of the distribution, e.g. if `p = 0.05` we expect typical fluctuations of samples from the negative binomial to be
about 5% of the mean when the mean is notably larger than 20. Otherwise, we expect approximately Poisson noise. In our opinion, this
parameterisation is useful for specifying the distribution in a way that is easier to reason on priors for `p`.

# Arguments:

- `r`: The number of successes, although this can be extended to a continous number.
- `p`: Success rate.

# Returns:

- A `SafeNegativeBinomial` distribution with the specified mean.

# Examples:

```jldoctest SafeNegativeBinomial
using EpiAware, Distributions

bigμ = exp(48.0) #Large value of μ
σ² = bigμ + 0.05 * bigμ^2 #Large variance

# We can calculate the success rate from the mean to variance relationship
p = bigμ / σ²
r = bigμ * p / (1 - p)
d = SafeNegativeBinomial(r, p)
# output
SafeNegativeBinomial{Float64}(r=20.0, p=2.85032816548187e-20)
```

```jldoctest SafeNegativeBinomial
cdf(d, 100)
# output
0.0
```

```jldoctest SafeNegativeBinomial
logpdf(d, 100)
# output
-850.1397180331871
```

```jldoctest SafeNegativeBinomial
mean(d)
# output
7.016735912097631e20
```

```jldoctest SafeNegativeBinomial
var(d)
# output
2.4617291430060293e40
```
"
struct SafeNegativeBinomial{T <: Real} <: SafeDiscreteUnivariateDistribution
    r::T
    p::T

    function SafeNegativeBinomial{T}(r::T, p::T) where {T <: Real}
        return new{T}(r, p)
    end
end

#Outer constructors make AD work
function SafeNegativeBinomial(r::T, p::T) where {T <: Real}
    return SafeNegativeBinomial{T}(r, p)
end

SafeNegativeBinomial(r::Real, p::Real) = SafeNegativeBinomial(promote(r, p)...)

# helper function
_negbin(d::SafeNegativeBinomial) = NegativeBinomial(d.r, d.p; check_args = false)

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

Distributions.mean(d::SafeNegativeBinomial) = _negbin(d) |> mean
Distributions.var(d::SafeNegativeBinomial) = _negbin(d) |> var
Distributions.std(d::SafeNegativeBinomial) = _negbin(d) |> std
Distributions.skewness(d::SafeNegativeBinomial) = _negbin(d) |> skewness
Distributions.kurtosis(d::SafeNegativeBinomial) = _negbin(d) |> kurtosis
Distributions.mode(d::SafeNegativeBinomial) = _negbin(d) |> mode
function Distributions.kldivergence(p::SafeNegativeBinomial, q::SafeNegativeBinomial)
    kldivergence(_negbin(p), _negbin(q))
end

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
    if isone(d.p)
        return 0
    else
        return rand(
            rng, SafePoisson(rand(rng, Gamma(d.r, (1 - d.p) / d.p; check_args = false))))
    end
end

Distributions.mgf(d::SafeNegativeBinomial, t::Real) = mgf(_negbin(d), t)
Distributions.cgf(d::SafeNegativeBinomial, t) = cgf(_negbin(d), t)
Distributions.cf(d::SafeNegativeBinomial, t::Real) = cf(_negbin(d), t)
