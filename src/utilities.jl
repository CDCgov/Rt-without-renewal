"""
    scan(f, init, xs)

Apply a function `f` to each element of `xs` along with an accumulator hidden state with intial
value `init`. The function `f` takes the current accumulator value and the current element of `xs` as 
arguments, and returns a new accumulator value and a result value. The function `scan` returns a tuple 
`(ys, carry)`, where `ys` is an array containing the result values and `carry` is the final accumulator 
value. This is similar to the JAX function `jax.lax.scan`.

# Arguments
- `f`: A function that takes an accumulator value and an element of `xs` as arguments and returns a new
    hidden state.
- `init`: The initial accumulator value.
- `xs`: An iterable collection of elements.

# Returns
- `ys`: An array containing the result values of applying `f` to each element of `xs`.
- `carry`: The final accumulator value.
"""
function scan(f, init, xs)
    carry = init
    ys = similar(xs)
    for (i, x) in enumerate(xs)
        carry, y = f(carry, x)
        ys[i] = y
    end
    return ys, carry
end

"""
    create_discrete_pmf(dist; Δd = 1.0, D)

Create a discrete probability mass function (PMF) from a given distribution.

Arguments:
- `dist`: The distribution from which to create the PMF.
- `Δd`: The step size for discretizing the domain. Default is 1.0.
- `D`: The upper bound of the domain. Must be greater than `Δd`.

Returns:
- A vector representing the PMF.

Raises:
- `AssertionError` if the minimum value of `dist` is negative.
- `AssertionError` if `Δd` is not positive.
- `AssertionError` if `D` is not greater than `Δd`.
"""
function create_discrete_pmf(dist::Distribution; Δd = 1.0, D)
    @assert minimum(dist) >= 0.0 "Distribution must be non-negative"
    @assert Δd > 0.0 "Δd must be positive"
    @assert D > Δd "D must be greater than Δd"
    ts = 0.0:Δd:D |> collect
    ts[end] != D && append!(ts, D)

    ts .|> (t -> cdf(dist, t)) |> diff |> p -> p ./ sum(p)
end

"""
    growth_rate_to_reproductive_ratio(r, w)

Compute the reproductive ratio given exponential growth rate `r` 
    and discretized generation interval `w`.

# Arguments
- `r`: The exponential growth rate.
- `w`: discretized generation interval.

# Returns
- The reproductive ratio.
"""
function growth_rate_to_reproductive_ratio(r, w::AbstractVector)
    return 1 / sum([w[i] * exp(-r * i) for i = 1:length(w)])
end


"""
    mean_cc_neg_bin(μ, α)

Compute the mean-cluster factor negative binomial distribution.

# Arguments
- `μ`: The mean of the distribution.
- `α`: The clustering factor parameter.

# Returns
A `NegativeBinomial` distribution object.
"""
function mean_cc_neg_bin(μ, α)
    ex_σ² = α * μ^2
    p = μ / (μ + ex_σ² + 1e-6)
    r = μ^2 / ex_σ²
    return NegativeBinomial(r, p)
end
