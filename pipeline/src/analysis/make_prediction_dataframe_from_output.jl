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
        output, true_mean_gi; qs = [0.025, 0.25, 0.5, 0.75, 0.975],
        transformation = oneexpy)
    #Unpack the output
    inference_config = output["inference_config"]
    forecasts = output["forecast_results"]
    #Get the scenario, IGP model, latent model and true mean GI
    igp_model = inference_config["igp"] |> igp_name -> split(igp_name, ".")[end]
    scenario = inference_config["scenario"]
    latent_model = inference_config["latent_model"]
    used_gi_mean = inference_config["gi_mean"]
    used_gi_std = inference_config["gi_std"]
    (start_time, reference_time) = inference_config["tspan"] |>
                                   tspan -> split(tspan, "_") |>
                                            tspan -> (
        parse(Int, tspan[1]), parse(Int, tspan[2]))

    #Get the quantiles for the targets across the gi mean scenarios
    #if Renewal model, then we use the underlying epi model
    #otherwise we use the epi datas to loop over different gi mean implications
    used_gi_means = igp_model == "Renewal" ?
                    [used_gi_mean] :
                    make_gi_params(EpiAwareExamplePipeline())["gi_means"]

    used_epidatas = map(used_gi_means) do ḡ
        _make_epidata(ḡ, used_gi_std; transformation = transformation)
    end

    preds = map(used_epidatas) do epi_data
        generate_quantiles_for_targets(forecasts, epi_data, qs)
    end

    #Create the dataframe columnwise
    df = mapreduce(vcat, preds, used_gi_means) do pred, used_gi_mean
        mapreduce(vcat, keys(pred)) do target
            target_mat = pred[target]
            target_times = collect(1:size(target_mat, 1)) .+ (start_time - 1)
            _df = DataFrame(target_times = target_times)
            _df[!, "Scenario"] .= scenario
            _df[!, "IGP_Model"] .= igp_model
            _df[!, "Latent_Model"] .= latent_model
            _df[!, "True_GI_Mean"] .= true_mean_gi
            _df[!, "Used_GI_Mean"] .= used_gi_mean
            _df[!, "Reference_Time"] .= reference_time
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
