"""
Generate an observation kernel matrix based on the given delay interval and time horizon.

# Arguments
- `delay_int::Vector{Float64}`: The delay PMF vector.
- `time_horizon::Int`: The number of time steps of the observation period.
- `partial::Bool`: Whether to generate a partial observation kernel matrix.

# Returns
- `K::SparseMatrixCSC{Float64, Int}`: The observation kernel matrix.
"""
function generate_observation_kernel(delay_int, time_horizon, partial = true)
    K = zeros(eltype(delay_int), time_horizon, time_horizon) |> SparseMatrixCSC
    if (partial)
        for i in 1:time_horizon
            K[i, i:(i + length(delay_int))] = delay_int
        end
    else
        for i in 1:time_horizon, j in 1:time_horizon
            m = i - j
            if m >= 0 && m <= (length(delay_int) - 1)
                K[i, j] = delay_int[m + 1]
            end
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
        _μ = clamp(μ, 1e-6, 1e17)
        _α = clamp(α, 1e-6, Inf)
        ex_σ² = (_α * _μ^2)
        p = clamp(_μ / (_μ + ex_σ²), 1e-17, 1 - 1e-17)
        r = clamp(_μ^2 / ex_σ², 1e-17, 1e17)
        return NegativeBinomial(r, p)
    end
end
