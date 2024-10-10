@doc raw"
Create a Poisson distribution with the specified mean that avoids `InExactError`
when the mean is too large.

# Arguments:

- `λ`: The mean of the Poisson distribution.

# Returns:

- A `SafePoisson` distribution with the specified mean.

# Examples:

```jldoctest SafePoisson
using EpiAware, Distributions

bigλ = exp(48.0) #Large value of λ
d = SafePoisson(bigλ)
# output
EpiAware.EpiAwareUtils.SafePoisson{Float64}(λ=7.016735912097631e20)
```

```jldoctest SafePoisson
cdf(d, 2)
# output
0.0
```

```jldoctest SafePoisson
logpdf(d, 100)
# output
-7.016735912097631e20
```

```jldoctest SafePoisson
mean(d)
# output
7.016735912097631e20
```

```jldoctest SafePoisson
var(d)
# output
7.016735912097631e20
```
"
struct SafePoisson{T <: Real} <: RealUnivariateDistribution
    λ::T

    SafePoisson{T}(λ::Real) where {T <: Real} = new{T}(λ)
    SafePoisson(λ::Real) = SafePoisson{eltype(λ)}(λ)
end

# Default outer constructor
SafePoisson() = SafePoisson{Float64}(1.0)

# helper functions
_poisson(d::SafePoisson) = Poisson(d.λ; check_args = false)

# ineffiecient but safe floor function to integer, which can handle large values of x
function _safe_int_floor(x::Real)
    Tf = typeof(x)
    if (Tf(typemin(Int)) - one(Tf)) < x < (Tf(typemax(Int)) + one(Tf))
        return floor(Int, x)
    else
        return floor(BigInt, x)
    end
end

function _safe_int_round(x::Real)
    Tf = typeof(x)
    if (Tf(typemin(Int)) - one(Tf)) < x < (Tf(typemax(Int)) + one(Tf))
        return round(Int, x)
    else
        return round(BigInt, x)
    end
end

### Parameters

Distributions.params(d::SafePoisson) = _poisson(d) |> params
Distributions.partype(::SafePoisson{T}) where {T} = T
Distributions.rate(d::SafePoisson) = d.λ

### Statistics

Distributions.mean(d::SafePoisson) = d.λ
Distributions.mode(d::SafePoisson) = floor(d.λ)
Distributions.var(d::SafePoisson) = d.λ
Distributions.skewness(d::SafePoisson) = one(typeof(d.λ)) / sqrt(d.λ)
Distributions.kurtosis(d::SafePoisson) = one(typeof(d.λ)) / d.λ

function Distributions.entropy(d::SafePoisson{T}) where {T <: Real}
    entropy(_poisson(d))
end

function Distributions.kldivergence(p::SafePoisson, q::SafePoisson)
    kldivergence(_poisson(p), _poisson(q))
end

### Evaluation

Distributions.mgf(d::SafePoisson, t::Real) = mgf(_poisson(d), t)
Distributions.cgf(d::SafePoisson, t) = cgf(_poisson(d), t)
Distributions.cf(d::SafePoisson, t::Real) = cf(_poisson(d), t)
Distributions.logpdf(d::SafePoisson, x::Real) = logpdf(_poisson(d), x)
Distributions.pdf(d::SafePoisson, x::Integer) = pdf(_poisson(d), x)
Distributions.cdf(d::SafePoisson, x::Integer) = cdf(_poisson(d), x)
Distributions.ccdf(d::SafePoisson, x::Integer) = ccdf(_poisson(d), x)
Distributions.quantile(d::SafePoisson, q::Real) = quantile(_poisson(d), q)

### Support

Base.minimum(d::SafePoisson) = 0
Base.maximum(d::SafePoisson) = Inf
Distributions.insupport(d::SafePoisson, x::Integer) = x >= 0

### Sampling
### Taken from PoissonRandom.jl https://github.com/SciML/PoissonRandom.jl/blob/master/src/PoissonRandom.jl

count_rand(λ) = count_rand(Random.GLOBAL_RNG, λ)
function count_rand(rng::AbstractRNG, λ)
    n = 0
    c = randexp(rng)
    while c < λ
        n += 1
        c += randexp(rng)
    end
    return n
end

# Algorithm from:
#
#   J.H. Ahrens, U. Dieter (1982)
#   "Computer Generation of Poisson Deviates from Modified Normal Distributions"
#   ACM Transactions on Mathematical Software, 8(2):163-179
#
#   For μ sufficiently large, (i.e. >= 10.0)
#
ad_rand(λ) = ad_rand(Random.GLOBAL_RNG, λ)
function ad_rand(rng::AbstractRNG, λ)
    s = sqrt(λ)
    d = 6.0 * λ^2
    L = floor(λ - 1.1484)
    # Step N
    G = λ + s * randn(rng)

    if G >= 0.0
        K = floor(G)
        # Step I
        if K >= L
            return K
        end

        # Step S
        U = rand(rng)
        if d * U >= (λ - K)^3
            return K
        end

        # Step P
        px, py, fx, fy = procf(λ, K, s)

        # Step Q
        if fy * (1 - U) <= py * exp(px - fx)
            return K
        end
    end

    while true
        # Step E
        E = randexp(rng)
        U = 2.0 * rand(rng) - 1.0
        T = 1.8 + copysign(E, U)
        if T <= -0.6744
            continue
        end

        K = floor(λ + s * T)
        px, py, fx, fy = procf(λ, K, s)
        c = 0.1069 / λ

        # Step H
        @fastmath if c * abs(U) <= py * exp(px + E) - fy * exp(fx + E)
            return K
        end
    end
end

# log(1+x)-x
# accurate ~2ulps for -0.227 < x < 0.315
function log1pmx_kernel(x::Float64)
    r = x / (x + 2.0)
    t = r * r
    w = @evalpoly(t,
        6.66666666666666667e-1, # 2/3
        4.00000000000000000e-1, # 2/5
        2.85714285714285714e-1, # 2/7
        2.22222222222222222e-1, # 2/9
        1.81818181818181818e-1, # 2/11
        1.53846153846153846e-1, # 2/13
        1.33333333333333333e-1, # 2/15
        1.17647058823529412e-1) # 2/17
    hxsq = 0.5 * x * x
    r * (hxsq + w * t) - hxsq
end

# use naive calculation or range reduction outside kernel range.
# accurate ~2ulps for all x
function log1pmx(x::Float64)
    if !(-0.7 < x < 0.9)
        return log1p(x) - x
    elseif x > 0.315
        u = (x - 0.5) / 1.5
        return log1pmx_kernel(u) - 9.45348918918356180e-2 - 0.5 * u
    elseif x > -0.227
        return log1pmx_kernel(x)
    elseif x > -0.4
        u = (x + 0.25) / 0.75
        return log1pmx_kernel(u) - 3.76820724517809274e-2 + 0.25 * u
    elseif x > -0.6
        u = (x + 0.5) * 2.0
        return log1pmx_kernel(u) - 1.93147180559945309e-1 + 0.5 * u
    else
        u = (x + 0.625) / 0.375
        return log1pmx_kernel(u) - 3.55829253011726237e-1 + 0.625 * u
    end
end

# Procedure F
function procf(λ, K, s::Float64)
    # can be pre-computed, but does not seem to affect performance
    ω = 0.3989422804014327 / s
    b1 = 0.041666666666666664 / λ
    b2 = 0.3 * b1 * b1
    c3 = 0.14285714285714285 * b1 * b2
    c2 = b2 - 15.0 * c3
    c1 = b1 - 6.0 * b2 + 45.0 * c3
    c0 = 1.0 - b1 + 3.0 * b2 - 15.0 * c3

    if K < 10
        px = -float(λ)
        py = λ^K / factorial(floor(Int, K))
    else
        δ = 0.08333333333333333 / K
        δ -= 4.8 * δ^3
        V = (λ - K) / K
        px = K * log1pmx(V) - δ # avoids need for table
        py = 0.3989422804014327 / sqrt(K)
    end
    X = (K - λ + 0.5) / s
    X2 = X^2
    fx = -0.5 * X2 # missing negation in pseudo-algorithm, but appears in fortran code.
    fy = ω * (((c3 * X2 + c2) * X2 + c1) * X2 + c0)
    return px, py, fx, fy
end

pois_rand(λ) = pois_rand(Random.GLOBAL_RNG, λ)
pois_rand(rng::AbstractRNG, λ) = λ < 6 ? count_rand(rng, λ) : ad_rand(rng, λ)

function Base.rand(rng::AbstractRNG, d::SafePoisson)
    pois_rand(rng, d.λ)
end
