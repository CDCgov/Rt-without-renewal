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
    return (:neg_bin_cluster_factor_prior => Gamma(3, 0.05 / 3),) |> Dict
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

    if should_vectorize(y_t)
        y_t ~ arraydist(NegativeBinomialMeanClust.(expected_obs, neg_bin_cluster_factor))
    else
        for i in eachindex(y_t)
            y_t[i] ~ NegativeBinomialMeanClust(expected_obs[i], neg_bin_cluster_factor)
        end
    end

    return y_t, (; neg_bin_cluster_factor,)
end

"""
    should_vectorize(y_t)

Determine whether the input `y_t` should be processed in a vectorized manner.
This is determined based on whether `y_t` is completely missing or if it is an array
with no missing values (vectorized processing is preferred) versus being an array with
some missing values (non-vectorized, individual processing is necessary).

# Arguments
- `y_t`: The input data which can be a scalar, vector, or `missing`.

# Returns
- `Boolean`: `true` if `y_t` should be processed in a vectorized manner, `false` otherwise.
"""
function should_vectorize(y_t)
    # Check if y_t is entirely missing, which implies non-vectorized processing
    if ismissing(y_t)
        return false
    end

    # If y_t is an array, check for any missing elements
    if isa(y_t, AbstractArray)
        return !any(ismissing, y_t)
    end

    # For all other cases, including scalar non-missing values, prefer vectorized processing
    return true
end
