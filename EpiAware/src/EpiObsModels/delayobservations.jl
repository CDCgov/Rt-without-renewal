struct DelayObservations{T <: AbstractFloat, S <: Sampleable} <: AbstractObservationModel
    delay_kernel::SparseMatrixCSC{T, Integer}
    neg_bin_cluster_factor_prior::S
    pos_shift::T

    function DelayObservations(delay_int,
            time_horizon,
            neg_bin_cluster_factor_prior;
            pos_shift = 1e-6)
        @assert all(delay_int .>= 0) "Delay interval must be non-negative"
        @assert sum(delay_int)≈1 "Delay interval must sum to 1"

        K = generate_observation_kernel(delay_int, time_horizon)

        new{eltype(K), typeof(neg_bin_cluster_factor_prior)}(K,
            neg_bin_cluster_factor_prior, pos_shift)
    end

    function DelayObservations(;
            delay_distribution::ContinuousDistribution,
            time_horizon::Integer,
            neg_bin_cluster_factor_prior::Sampleable,
            D_delay,
            Δd = 1.0,
            pos_shift = 1e-6)
        delay_int = create_discrete_pmf(delay_distribution; Δd = Δd, D = D_delay)
        return DelayObservations(
            delay_int, time_horizon, neg_bin_cluster_factor_prior; pos_shift)
    end
end

function default_delay_obs_priors()
    return (:neg_bin_cluster_factor_prior => truncated(
        Normal(0, 0.1 * sqrt(pi) / sqrt(2)), 0.0, Inf),) |> Dict
end

@model function EpiAwareBase.generate_observations(observation_model::DelayObservations,
        y_t,
        I_t)

    #Parameters
    neg_bin_cluster_factor ~ observation_model.neg_bin_cluster_factor_prior

    #Predictive distribution
    expected_obs = observation_model.delay_kernel * I_t .+ observation_model.pos_shift

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
