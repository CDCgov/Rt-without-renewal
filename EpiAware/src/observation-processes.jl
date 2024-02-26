abstract type AbstractObservationModel end

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
    case_pred_dists = (observation_model.delay_kernel * I_t) .+ pos_shift .|>
                      μ -> mean_cc_neg_bin(μ, neg_bin_cluster_factor)

    #Likelihood
    y_t ~ arraydist(case_pred_dists)

    return y_t, (; neg_bin_cluster_factor,)
end
