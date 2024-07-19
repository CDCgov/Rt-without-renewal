"""
Create a dataframe containing prediction results based on the given output and input data.

# Arguments
- `filename`: The name of the file.
- `output`: The output data containing inference configuration, IGP model, and other information.
- `epi_datas`: The input data for the epidemiological model.
- `qs`: An optional array of quantiles to calculate. Default is `[0.025, 0.5, 0.975]`.

# Returns
A dataframe containing the prediction results.

"""
function make_prediction_dataframe_from_output(
        filename, output, epi_datas, pipelines; qs = [0.025, 0.5, 0.975],
        used_gi_means = [2.0, 10.0, 20.0])
    #Get the scenario, IGP model, latent model and true mean GI
    inference_config = output["inference_config"]
    igp_model = output["inference_config"].igp |> string
    scenario = EpiAwarePipeline._get_scenario_from_filename(filename, pipelines)
    latent_model = EpiAwarePipeline._get_latent_model_from_filename(filename)
    true_mean_gi = EpiAwarePipeline._get_true_gi_mean_from_filename(filename)

    #Get the quantiles for the targets across the gi mean scenarios
    #if Renewal model, then we use the underlying epi model
    #otherwise we use the epi datas to loop over different gi mean implications
    used_epi_datas = igp_model == "Renewal" ? [output["epiprob"].epi_model.data] : epi_datas

    preds = nothing
    try
        preds = map(used_epi_datas) do epi_data
            generate_quantiles_for_targets(output, epi_data, qs)
        end
        used_gi_means = igp_model == "Renewal" ?
                        [EpiAwarePipeline._get_used_gi_mean_from_filename(filename)] :
                        used_gi_means

        #Create the dataframe columnwise
        df = mapreduce(vcat, preds, used_gi_means) do pred, used_gi_mean
            mapreduce(vcat, keys(pred)) do target
                target_mat = pred[target]
                target_times = collect(1:size(target_mat, 1)) .+
                               (inference_config.tspan[1] - 1)
                _df = DataFrame(target_times = target_times)
                _df[!, "Scenario"] .= scenario
                _df[!, "IGP_Model"] .= igp_model
                _df[!, "Latent_Model"] .= latent_model
                _df[!, "True_GI_Mean"] .= true_mean_gi
                _df[!, "Used_GI_Mean"] .= used_gi_mean
                _df[!, "Reference_Time"] .= inference_config.tspan[2]
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
    catch
        @warn "Error in generating quantiles for targets in file $filename"
        return nothing
    end
end
