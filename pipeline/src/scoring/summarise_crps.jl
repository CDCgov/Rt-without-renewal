"""
Summarizes the Continuous Ranked Probability Score (CRPS) for different processes based on the inference results.

# Arguments
- `inference_results`: A dictionary containing the inference results, including
    the forecast results and inference configuration.

# Returns
A dictionary containing the summarized CRPS scores for different processes.

"""
function summarise_crps(config, inference_results, forecast_results, epidata)
    ts = config.tspan[1]:min(config.tspan[2]+config.lookahead, length(config.truth_I_t))

    procs_names = (:log_I_t, :rt, :Rt, :I_t, :log_Rt)
    scores_log_I_t, scores_rt,
    scores_Rt,
    scores_I_t,
    scores_log_Rt = _process_crps_scores(
        procs_names, inference_results, forecast_results, config, ts, epidata)

    scores_y_t, scores_log_y_t = _cases_crps_scores(forecast_results, config, ts)

    return Dict("ts" => ts, "scores_log_I_t" => scores_log_I_t,
        "scores_rt" => scores_rt, "scores_Rt" => scores_Rt,
        "scores_I_t" => scores_I_t, "scores_log_Rt" => scores_log_Rt,
        "scores_y_t" => scores_y_t, "scores_log_y_t" => scores_log_y_t)
end

function _get_predicted_proc(inference_results, forecast_results, epidata, process)
    gens = forecast_results.generated
    log_I0s = inference_results.samples[:init_incidence]
    predicted_proc = mapreduce(hcat, gens, log_I0s) do gen, logI0
        I0 = exp(logI0)
        It = gen.I_t
        procs = calculate_processes(It, I0, epidata)
        getfield(procs, process)
    end
    return predicted_proc
end

function _get_predicted_y_t(forecast_results)
    gens = forecast_results.generated
    predicted_y_t = mapreduce(hcat, gens) do gen
        gen.generated_y_t
    end
    return predicted_y_t
end

"""
Internal method for calculating the CRPS scores for different processes.
"""
function _process_crps_scores(
        procs_names, inference_results, forecast_results, config, ts, epidata)
    map(procs_names) do process
        # Calculate the processes for the truth data
        true_Itminusone = ts[1] - 1 == 0 ? config.truth_I0 : config.truth_I_t[ts[1] - 1]
        true_proc = calculate_processes(
            config.truth_I_t[ts], true_Itminusone, epidata) |>
                    procs -> getfield(procs, process)
        # predictions
        predicted_proc = _get_predicted_proc(
            inference_results, forecast_results, epidata, process)
        scores = [simple_crps(preds, true_proc[t])
                  for (t, preds) in enumerate(eachrow(predicted_proc))]
        return scores
    end
end

"""
Internal method for calculating the CRPS scores for observed cases and log(cases),
    including the forecast score for future cases.
"""
function _cases_crps_scores(forecast_results, config, ts; jitter = 1e-6)
    true_y_t = config.case_data[ts]
    predicted_y_t = _get_predicted_y_t(forecast_results)
    scores_y_t = [simple_crps(preds, true_y_t[t])
                  for (t, preds) in enumerate(eachrow(predicted_y_t))]
    scores_log_y_t = [simple_crps(log.(preds .+ jitter), log(true_y_t[t] + jitter))
                      for (t, preds) in enumerate(eachrow(predicted_y_t))]
    return scores_y_t, scores_log_y_t
end
