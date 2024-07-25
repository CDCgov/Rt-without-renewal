"""
Create a dataframe containing scoring results based on the given output and input data.

NB: For non-Renewal infection generating processes (IGP), the function loops over
different GI mean scenarios to generate the CRPS scores. The reason for this is that
for these IGPs the choice of GI is not used in forward simulation, and so we calculate the
effects on inference in post-inference.

# Arguments
- `filename`: The name of the file.
- `output`: The output data containing inference configuration, IGP model, and other information.
- `epi_datas`: The input data for the epidemiological model.

# Returns
A dataframe containing the CRPS scoring results.

"""
function make_scoring_dataframe_from_output(
        filename, output, epi_datas, pipelines; qs = [0.025, 0.5, 0.975])
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

    try
        summaries = map(used_epi_datas) do epi_data
            summarise_crps(config, inference_results, forecast_results, epi_data)
        end
        used_gi_means = igp_model == "Renewal" ?
                        [EpiAwarePipeline._get_used_gi_mean_from_filename(filename)] :
                        make_gi_params(EpiAwareExamplePipeline())["gi_means"]

        #Create the dataframe columnwise
        df = mapreduce(vcat, summaries, used_gi_means) do summary, used_gi_mean
            _df = DataFrame()
            _df[!, "Scenario"] .= scenario
            _df[!, "IGP_Model"] .= igp_model
            _df[!, "Latent_Model"] .= latent_model
            _df[!, "True_GI_Mean"] .= true_mean_gi
            _df[!, "Used_GI_Mean"] .= used_gi_mean
            _df[!, "Reference_Time"] .= inference_config.tspan[2]
            for name in keys(summary)
                _df[!, name] = summary[name]
            end
        end
        return df
    catch
        @warn "Error in generating crps summaries for targets in file $filename"
        return nothing
    end
end
