"""
Collects the statistics of a vector `x` that are relevant for MCMC diagnostics.
"""
function _get_stats(x, threshold; pass_above = true)
    if pass_above
        return (; x_mean = mean(x), prop_pass = mean(x .>= threshold),
            x_min = minimum(x), x_max = maximum(x))
    else
        return (; x_mean = mean(x), prop_pass = mean(x .<= threshold),
            x_min = minimum(x), x_max = maximum(x))
    end
end

"""
Collects the convergence statistics over the parameters that are not cluster factor.
"""
function _collect_stats(chn_nt, not_cluster_factor; bulk_ess_threshold,
        tail_ess_threshold, rhat_diff_threshold)
    ess_bulk = chn_nt.ess_bulk[not_cluster_factor] |> x -> _get_stats(x, bulk_ess_threshold)
    ess_tail = chn_nt.ess_tail[not_cluster_factor] |> x -> _get_stats(x, tail_ess_threshold)
    rhat_diff = abs.(chn_nt.rhat[not_cluster_factor] .- 1) |>
                x -> _get_stats(x, rhat_diff_threshold; pass_above = false)
    return (; ess_bulk, ess_tail, rhat_diff)
end

"""
Generate a DataFrame containing MCMC diagnostic metrics. The metrics are the proportion of
parameters that pass the bulk effective sample size (ESS) threshold, the proportion of
parameters that pass the tail ESS threshold, the proportion of parameters that pass the R-hat
absolute difference from 1 threshold, whether the model has a cluster factor parameter, and the tail ESS
of the cluster factor parameter.

# Arguments
- `output::Dict`: A dictionary containing the inference results.
- `bulk_ess_threshold::Int`: The threshold for bulk effective sample size (ESS). Default is 500.
- `tail_ess_threshold::Int`: The threshold for tail effective sample size (ESS). Default is 100.
- `rhat_diff_threshold::Float64`: The threshold for the difference of R-hat from 1. Default is 0.02.
"""
function make_mcmc_diagnostic_dataframe(
        output, true_mean_gi, scenario; bulk_ess_threshold = 500,
        tail_ess_threshold = 100, rhat_diff_threshold = 0.02)
    #Get the scenario, IGP model, latent model and true mean GI
    inference_config = output["inference_config"]
    info = _get_info_from_config(inference_config)
    #Get the convergence diagnostics
    chn_nt = output["inference_results"].samples |> summarize |> summary -> summary.nt
    cluster_factor_idxs = chn_nt.parameters .== Symbol("obs.cluster_factor")
    has_cluster_factor = any(cluster_factor_idxs)
    not_cluster_factor = .~cluster_factor_idxs
    cluster_factor_tail = chn_nt.ess_tail[cluster_factor_idxs][1]
    #Collect the statistics
    stats_for_targets = _collect_stats(chn_nt, not_cluster_factor; bulk_ess_threshold,
        tail_ess_threshold, rhat_diff_threshold)

    #Create the dataframe
    df = mapreduce(vcat, info.used_gi_means) do used_gi_mean
        DataFrame(
            Scenario = scenario,
            igp_model = info.igp_model,
            latent_model = info.latent_model,
            True_GI_Mean = true_mean_gi,
            used_gi_mean = used_gi_mean,
            reference_time = info.reference_time,
            has_cluster_factor = has_cluster_factor,
            cluster_factor_tail = has_cluster_factor ? cluster_factor_tail : missing)
    end
    #Add stats columns
    for key in keys(stats_for_targets)
        stats = getfield(stats_for_targets, key)
        df[!, string(key) * "_" * "mean"] .= stats.x_mean
        df[!, string(key) * "_" * "prop_pass"] .= stats.prop_pass
        df[!, string(key) * "_" * "min"] .= stats.x_min
        df[!, string(key) * "_" * "max"] .= stats.x_max
    end
    return df
end
