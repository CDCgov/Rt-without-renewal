"""
Compute the negative moment generating function (MGF) for a given rate `r` and weights `w`.

# Arguments
- `r`: The rate parameter.
- `w`: An abstract vector of weights.

# Returns
The value of the negative MGF.

"""
function neg_MGF(r, w::AbstractVector)
    return sum([w[i] * exp(-r * i) for i in 1:length(w)])
end

function dneg_MGF_dr(r, w::AbstractVector)
    return -sum([w[i] * i * exp(-r * i) for i in 1:length(w)])
end

"""
This function computes an approximation to the exponential growth rate `r`
given the reproductive ratio `R₀` and the discretized generation interval `w` with
discretized interval width `Δd`. This is based on the implicit solution of

```math
G(r) - {1 \\over R_0} = 0.
```

where

```math
G(r) = \\sum_{i=1}^n w_i e^{-r i}.
```

is the negative moment generating function (MGF) of the generation interval distribution.

The two step approximation is based on:
    1. Direct solution of implicit equation for a small `r` approximation.
    2. Improving the approximation using Newton's method for a fixed number of steps `newton_steps`.

Returns:
- The approximate value of `r`.
"""
function R_to_r(R₀, w::Vector{T}; newton_steps = 2, Δd = 1.0) where {T <: AbstractFloat}
    mean_gen_time = dot(w, 1:length(w)) * Δd
    # Small r approximation as initial guess
    r_approx = (R₀ - 1) / (R₀ * mean_gen_time)
    # Newton's method
    for _ in 1:newton_steps
        r_approx -= (R₀ * neg_MGF(r_approx, w) - 1) / (R₀ * dneg_MGF_dr(r_approx, w))
    end
    return r_approx
end

function R_to_r(R₀, epi_model::AbstractTuringEpiModel; newton_steps = 2, Δd = 1.0)
    R_to_r(R₀, epi_model.data.gen_int; newton_steps = newton_steps, Δd = Δd)
end

"""
    r_to_R(r, w)

Compute the reproductive ratio given exponential growth rate `r`
    and discretized generation interval `w`.

# Arguments
- `r`: The exponential growth rate.
- `w`: discretized generation interval.

# Returns
- The reproductive ratio.
"""
function r_to_R(r, w::AbstractVector)
    return 1 / neg_MGF(r, w::AbstractVector)
end
