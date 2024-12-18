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

    #Create the dataframe
    df = mapreduce(vcat, info.used_gi_means) do used_gi_mean
        DataFrame(
            Scenario = scenario,
            igp_model = info.igp_model,
            latent_model = info.latent_model,
            True_GI_Mean = true_mean_gi,
            used_gi_mean = used_gi_mean,
            reference_time = info.reference_time,
            bulk_ess_threshold = (chn_nt.ess_bulk[not_cluster_factor] .>
                                  bulk_ess_threshold) |>
                                 mean,
            tail_ess_threshold = (chn_nt.ess_tail[not_cluster_factor] .>
                                  tail_ess_threshold) |>
                                 mean,
            rhat_diff_threshold = (abs.(chn_nt.rhat[not_cluster_factor] .- 1) .<
                                   rhat_diff_threshold) |> mean,
            has_cluster_factor = has_cluster_factor,
            cluster_factor_tail = has_cluster_factor ? cluster_factor_tail : missing)
    end
    return df
end
