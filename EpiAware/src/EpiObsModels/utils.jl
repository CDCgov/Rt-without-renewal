"""
Generate an observation kernel matrix based on the given delay interval and time horizon.

# Arguments
- `delay_int::Vector{Float64}`: The delay PMF vector.
- `time_horizon::Int`: The number of time steps of the observation period.
- `partial::Bool`: Whether to generate a partial observation kernel matrix.

# Returns
- `K::SparseMatrixCSC{Float64, Int}`: The observation kernel matrix.
"""
function generate_observation_kernel(delay_int, time_horizon; partial::Bool = true)
    if (partial)
        K = zeros(eltype(delay_int), time_horizon, time_horizon) |> SparseMatrixCSC
        for i in 1:time_horizon, j in 1:time_horizon
            m = i - j
            if m >= 0 && m <= (length(delay_int) - 1)
                K[i, j] = delay_int[m + 1]
            end
        end
    else
        com_time = time_horizon - length(delay_int) + 1
        K = zeros(eltype(delay_int), com_time, time_horizon) |> SparseMatrixCSC
        for i in 1:com_time
            K[i, i:(i + length(delay_int) - 1)] = delay_int
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
    μ² = μ^2
    ex_σ² = α * μ²
    p = μ / (μ + ex_σ²)
    r = μ² / ex_σ²
    return NegativeBinomial(r, p)
end
