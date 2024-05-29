"""
Generate an observation kernel matrix based on the given delay interval and time horizon.

# Arguments
- `delay_int::Vector{Float64}`: The delay PMF vector.
- `time_horizon::Int`: The number of time steps of the observation period.

# Returns
- `K::SparseMatrixCSC{Float64, Int}`: The observation kernel matrix.
"""
function generate_observation_kernel(delay_int, time_horizon)
    K = zeros(eltype(delay_int), time_horizon, time_horizon) |> SparseMatrixCSC
    for i in 1:time_horizon, j in 1:time_horizon
        m = i - j
        if m >= 0 && m <= (length(delay_int) - 1)
            K[i, j] = delay_int[m + 1]
        end
    end
    return K
end

"""
Compute the mean-cluster factor negative binomial distribution.

# Arguments
- `μ`: The mean of the distribution.
- `α`: The clustering factor parameter.

# Returns
A `NegativeBinomial` distribution object.
"""
function NegativeBinomialMeanClust(μ, α)
    if isnan(μ) || isnan(α)
        return DiscreteUniform(0, 1_000_000)
    else
        r = clamp(1 / α, nextfloat(zero(α)), prevfloat(typemax(α)))
        p = clamp(1 / (1 + α * μ), nextfloat(zero(μ)), one(μ))
        return NegativeBinomial(r, p)
    end
end
