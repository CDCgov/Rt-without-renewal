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

struct DelayObservations{T <: AbstractFloat, S <: Sampleable} <: AbstractObservationModel
    delay_kernel::SparseMatrixCSC{T, Integer}
    neg_bin_cluster_factor_prior::S

    function DelayObservations(delay_int,
            time_horizon,
            neg_bin_cluster_factor_prior)
        @assert all(delay_int .>= 0) "Delay interval must be non-negative"
        @assert sum(delay_int)≈1 "Delay interval must sum to 1"

        K = generate_observation_kernel(delay_int, time_horizon)

        new{eltype(K), typeof(neg_bin_cluster_factor_prior)}(K,
            neg_bin_cluster_factor_prior)
    end

    function DelayObservations(;
            delay_distribution::ContinuousDistribution,
            time_horizon::Integer,
            neg_bin_cluster_factor_prior::Sampleable,
            D_delay,
            Δd = 1.0)
        delay_int = create_discrete_pmf(delay_distribution; Δd = Δd, D = D_delay)
        return DelayObservations(delay_int, time_horizon, neg_bin_cluster_factor_prior)
    end
end

function default_delay_obs_priors()
    return (:neg_bin_cluster_factor_prior => truncated(
        Normal(0, 0.1 * sqrt(pi) / sqrt(2)), 0.0, Inf),) |> Dict
end

function generate_observations(observation_model::AbstractObservationModel,
        y_t,
        I_t;
        pos_shift)
    @info "No concrete implementation for generate_observations is defined."
    return nothing
end

@model function generate_observations(observation_model::DelayObservations,
        y_t,
        I_t;
        pos_shift)

    #Parameters
    neg_bin_cluster_factor ~ observation_model.neg_bin_cluster_factor_prior

    #Predictive distribution
    expected_obs = observation_model.delay_kernel * I_t .+ pos_shift

    if ismissing(y_t)
        y_t = Vector{Int}(undef, length(expected_obs))
    end

    for i in eachindex(y_t)
        y_t[i] ~ NegativeBinomialMeanClust(
            expected_obs[i], neg_bin_cluster_factor^2
        )
    end

    return y_t, (; neg_bin_cluster_factor,)
end
