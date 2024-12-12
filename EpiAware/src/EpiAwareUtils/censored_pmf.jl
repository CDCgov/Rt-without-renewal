@doc raw"
Create a discrete probability mass function (PMF) from a given distribution, assuming that the
primary event happens at `primary_approximation_point * Δd` within an intial censoring interval. Common
single-censoring approximations are `primary_approximation_point = 0` (left-hand approximation),
`primary_approximation_point = 1` (right-hand) and `primary_approximation_point = 0.5` (midpoint).

# Arguments
- `dist`: The distribution from which to create the PMF.
- ::Val{:single_censored}: A dummy argument to dispatch to this method. The purpose of the `Val`
type argument is that to use `single-censored` approximation is an active decision.
- `primary_approximation_point`: A approximation point for the primary time in its censoring interval.
Default is 0.5 for midpoint approximation.
- `Δd`: The step size for discretizing the domain. Default is 1.0.
- `D`: The upper bound of the domain. Must be greater than `Δd`.

# Returns
- A vector representing the PMF.

Raises:
- `AssertionError` if the minimum value of `dist` is negative.
- `AssertionError` if `Δd` is not positive.
- `AssertionError` if `D` is not greater than `Δd`.

# Examples

```jldoctest; output = false
using Distributions
using EpiAware.EpiAwareUtils

dist = Exponential(1.0)

censored_pmf(dist, Val(:single_censored); D = 10)
nothing

# output

```
"
function censored_pmf(dist::Distribution,
        ::Val{:single_censored};
        primary_approximation_point = 0.5,
        Δd = 1.0,
        D)
    @assert minimum(dist)>=0.0 "Distribution must be non-negative"
    @assert Δd>0.0 "Δd must be positive"
    @assert D>Δd "D must be greater than Δd"
    @assert primary_approximation_point >= 0.0&&primary_approximation_point <= 1.0 "`primary_approximation_point` must be in [0,1]."

    ts = Δd:Δd:D |> collect
    @assert ts[end]==D "D must be a multiple of Δd."
    ts = [primary_approximation_point * Δd; ts] #This covers situation where primary_approximation_point == 1

    ts .|> (t -> cdf(dist, t)) |> diff |> p -> p ./ sum(p)
end

"""
Internal function to check censored_pmf arguments and return the time steps of the rightmost limits of the censor intervals.
"""
function _check_and_give_ts(dist::Distribution, Δd, D, upper)
    @assert minimum(dist)>=0.0 "Distribution must be non-negative."
    @assert Δd>0.0 "Δd must be positive."

    if isnothing(D)
        x_99 = invlogcdf(dist, log(upper))
        D = round(Int64, x_99 / Δd) * Δd
    end

    @assert D>=Δd "D can't be shorter than Δd."

    ts = Δd:Δd:D |> collect

    @assert ts[end]==D "D must be a multiple of Δd."

    return ts
end

"""
Calculate the CDF of the random variable `X + U` where `X` has cumulative distriubtion function `F`
and `U` is a uniform random variable on `[0, Δd)`.

This is used in solving for censored CDFs and PMFs using numerical quadrature.
"""
function ∫F(dist, t, Δd)
    quadgk(u -> exp(logcdf(dist, t - u) - log(Δd)), 0.0, min(Δd, t))[1]
end

@doc raw"
Create a discrete probability cumulative distribution function (CDF) from a given distribution,
assuming a uniform distribution over primary event times with censoring intervals of width `Δd` for
both primary and secondary events.

NB: `censored_cdf` returns the _non-truncated_ CDF, i.e. the CDF without conditioning on the
secondary event occuring either before or after some time.


# Arguments
- `dist`: The distribution from which to create the PMF.
- `Δd`: The step size for discretizing the domain. Default is 1.0.
- `D`: The upper bound of the domain. Must be greater than `Δd`. Default `D = nothing`
indicates that the distribution should be truncated at its `upper`th percentile rounded
to nearest multiple of `Δd`.


# Returns
- A vector representing the CDF with 0.0 appended at the beginning.

# Raises
- `AssertionError` if the minimum value of `dist` is negative.
- `AssertionError` if `Δd` is not positive.
- `AssertionError` if `D` is shorter than `Δd`.
- `AssertionError` if `D` is not a multiple of `Δd`.

# Examples

```jldoctest filter; output = false
using Distributions
using EpiAware.EpiAwareUtils

dist = Exponential(1.0)

censored_cdf(dist; D = 10)
nothing

# output

```
"
function censored_cdf(dist::Distribution; Δd = 1.0, D = nothing, upper = 0.999)
    ts = _check_and_give_ts(dist, Δd, D, upper)
    cens_F = ts .|> t -> ∫F(dist, t, Δd)
    return [0.0; cens_F]
end

@doc raw"
Create a discrete probability mass function (PMF) from a given distribution,
assuming a uniform distribution over primary event times with censoring intervals of width `Δd` for
both primary and secondary events. The CDF for the time from the left edge of the interval
containing the primary event to the secondary event is created by direct numerical integration (quadrature)
of the convolution of the CDF of `dist` with the uniform density on `[0,Δd)`, using the `censored_cdf`
function. The discrete PMF for double censored delays is then found using simple differencing
on the CDF.

NB: `censored_pmf` returns a _right-truncated_ PMF, i.e. the PMF conditioned on the secondary event
occurring before or on the final secondary censoring window.


# Arguments
- `dist`: The distribution from which to create the PMF.
- `Δd`: The step size for discretizing the domain. Default is 1.0.
- `D`: The upper bound of the domain. Must be greater than `Δd`. Default `D = nothing`
indicates that the distribution should be truncated at its `upper`th percentile rounded
to nearest multiple of `Δd`.


# Returns
- A vector representing the PMF.

# Raises
- `AssertionError` if the minimum value of `dist` is negative.
- `AssertionError` if `Δd` is not positive.
- `AssertionError` if `D` is shorter than `Δd`.
- `AssertionError` if `D` is not a multiple of `Δd`.

# Examples

```jldoctest filter; output = false
using Distributions
using EpiAware.EpiAwareUtils

dist = Exponential(1.0)

censored_pmf(dist; D = 10)
nothing

# output

```
"
function censored_pmf(dist::Distribution; Δd = 1.0, D = nothing, upper = 0.99)
    cens_cdf = censored_cdf(dist; Δd, D, upper)
    return cens_cdf |> diff |> p -> p ./ sum(p)
end
