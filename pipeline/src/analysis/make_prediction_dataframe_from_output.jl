"""
Create a dataframe containing prediction results based on the given output and input data.

# Arguments
- `filename`: The name of the file.
- `output`: The output data containing inference configuration, IGP model, and other
using Base: infer_effects
    information.
- `epi_datas`: The input data for the epidemiological model.
- `qs`: An optional array of quantiles to calculate. Default is `[0.025, 0.5, 0.975]`.

# Returns
A dataframe containing the prediction results.

"""
function make_prediction_dataframe_from_output(
        output, true_mean_gi, scenario; qs = [0.025, 0.25, 0.5, 0.75, 0.975],
        transformation = oneexpy)
    #Unpack the output
    inference_config = output["inference_config"]
    forecasts = output["forecast_results"]
    #Get the scenario, IGP model, latent model and true mean GI
    info = _get_info_from_config(inference_config)
    #Get the epi datas
    used_epidatas = map(info.used_gi_means) do ḡ
        _make_epidata(ḡ, info.used_gi_std; transformation = transformation)
    end
    #Generate the quantiles for the targets
    preds = map(used_epidatas) do epi_data
        generate_quantiles_for_targets(forecasts, epi_data, qs)
    end

    #Create the dataframe columnwise
    df = mapreduce(vcat, preds, info.used_gi_means) do pred, used_gi_mean
        mapreduce(vcat, keys(pred)) do target
            target_mat = pred[target]
            target_times = collect(1:size(target_mat, 1)) .+ (info.start_time - 1)
            _df = DataFrame(target_times = target_times)
            _df[!, "Scenario"] .= scenario
            _df[!, "igp_model"] .= info.igp_model
            _df[!, "latent_model"] .= info.latent_model
            _df[!, "True_GI_Mean"] .= true_mean_gi
            _df[!, "used_gi_mean"] .= used_gi_mean
            _df[!, "reference_time"] .= info.reference_time
            _df[!, "Target"] .= string(target)
            # quantile predictions
            for (j, q) in enumerate(qs)
                q_str = split(string(q), ".")[end]
                _df[!, "q_$(q_str)"] = target_mat[:, j]
            end
            return _df
        end
    end
    return df
end
