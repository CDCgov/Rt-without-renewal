@doc raw"
The `FixedDelay` struct represents a fixed delay model used in infectious disease modeling.

## Constructors

- `FixedDelay(pmf)`. Constructs a `FixedDelay` object with a probability mass function `pmf` for the delay distribution.
- `FixedDelay(; pmf::Vector{Real} = [1.0], lower_interval::Int = 0)`. Constructs a `FixedDelay` object with a default probability mass function `pmf` of [1.0] and a lower interval for the delay distribution.
- `FixedDelay(; distribution::ContinuousDistribution, D, Δd = 1.0, lower_interval::Int = 0)`. Constructs a `FixedDelay` object with a double interval censoring discretization of the continuous delay distribution `distribution`. `D` sets the right truncation point, `Δd` sets the interval width (default = 1.0), and `lower_interval` sets the lower interval for the delay distribution.

## Examples
Construction direct from probability mass function:


"
struct FixedDelay{T <: Real, F <: Function} <: AbstractTuringDelayModel
    "Probability mass function for the delay distibution."
    pmf::Vector{T}
    "Length of the discrete delay distribution."
    len_pmf::Integer

    function FixedDelay(pmf, lower_interval)
        @assert all(pmf .>= 0) "Delay distribution must be non-negative"
        @assert sum(pmf)≈1 "Delay distribution must sum to 1"
        trunc_pmf = pmf[(lower_interval +1):end] |>
                    p -> p ./ sum(p)
        new{eltype(pmf)}(trunc_pmf, length(trunc_pmf))
    end

    function FixedDelay(; pmf::Vector{Real} = [1.0], lower_interval::Int = 0)
        return FixedDelay(pmf, lower_interval)
    end

    function FixedDelay(; distribution::ContinuousDistribution, D, Δd = 1.0,
                          lower_interval::Int = 0)
        pmf = censored_pmf(distribution, Δd = Δd, D = D)
        return FixedDelay(pmf, lower_interval)
    end
end
