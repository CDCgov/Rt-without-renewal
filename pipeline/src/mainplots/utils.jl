
"""
Transforms a matrix of time series samples into quantiles.

This function takes a matrix `X` where each row represents a time series and transforms
    it into a matrix of quantiles. The `qs` argument specifies the quantiles to compute.

# Arguments
- `X`: A matrix of time series samples in shape (num_time_points, num_samples).
- `qs`: A vector of quantiles to compute.

# Returns
A matrix where each row represents the quantiles of a time series.
"""
function timeseries_samples_into_quantiles(X, qs)
    mapreduce(vcat, eachrow(X)) do row
        quantile(row, qs)'
    end
end

"""
Internal function for reducing a sequence of results from calls to `calculate_processes`.
"""
_process_reduction(procs_1, procs_2) = (; log_I_t = hcat(procs_1.log_I_t, procs_2.log_I_t),
    Rt = hcat(procs_1.Rt, procs_2.Rt), rt = hcat(procs_1.rt, procs_2.rt))

"""
Generate quantiles for targets based on the output and EpiData.

# Arguments
- `output`: The output containing inference results.
- `D::EpiData`: The `EpiData` object containing data about underlying infection process,
    e.g. the generation interval distribution.
- `qs`: The quantiles to generate.

# Returns
An array of quantiles for each target.

"""
function generate_quantiles_for_targets(output, D::EpiData, qs)
    mapreduce(_process_reduction, output["forecast_results"].generated,
        output["inference_results"].samples[:init_incidence]) do gen, logI0
        calculate_processes(gen.I_t, exp(logI0), D, EpiAwareExamplePipeline())
    end |> res -> map(res) do X
        timeseries_samples_into_quantiles(X, qs)
    end
end

"""
Internal method to get a list of truth data scenarios from a vector of pipelines.
"""
function _get_scenario_list(pipelines::Vector{<:AbstractEpiAwarePipeline})
    map(pipelines) do pipeline
        _prefix_from_pipeline(pipeline)
    end
end

"""
Internal method to get a list of truth data mean generation intervals
"""
function _get_truth_mean_gi_string_list(pipelines::Vector{<:AbstractEpiAwarePipeline})
    gi_params = make_gi_params(pipelines[1])
    gi_mean_strs = gi_params["gi_means"] .|> x -> "gi_mean=$(x)"
    gi_mean_strs
end

"""
Create a dictionary mapping scenarios and GI mean strings to truth data.

# Arguments
- `pipelines::Vector{<:AbstractEpiAwarePipeline}`: A vector of pipelines.
- `truth_data_dir::String`: The directory where the truth data files are stored. Default is "truth_data".

# Returns
A dictionary mapping scenarios and GI mean strings to the corresponding truth data.
"""
function make_truth_data_dict(pipelines::Vector{<:AbstractEpiAwarePipeline};
        truth_data_dir::String = "truth_data")
    truth_data_files = readdir(datadir(truth_data_dir)) |>
                       strs -> filter(s -> occursin("jld2", s), strs)

    scenario_list = _get_scenario_list(pipelines)
    gi_mean_strs = _get_truth_mean_gi_string_list(pipelines)

    map(Iterators.product(scenario_list, gi_mean_strs)) do (scenario, gi_mean_str)
        filename = filter(name -> occursin(scenario, name) && occursin(gi_mean_str, name),
            truth_data_files)
        @assert length(filename)==1 "More than one Truth data file found"

        D = JLD2.load(joinpath(datadir(truth_data_dir), first(filename)))
        (scenario, gi_mean_str) => D
    end |> Dict
end

"""
Internal method to get the scenario from a filename.
"""
function _get_scenario_from_filename(
        filename, pipelines::Vector{<:AbstractEpiAwarePipeline})
    sc_list = _get_scenario_list(pipelines)
    scenario = filter(sc -> occursin(sc, filename), sc_list)[1]
end

"""
Internal method to get the latent model from a filename.
"""
function _get_latent_model_from_filename(filename;
        latent_namemodels::Vector{String} = ["wkly_ar", "wkly_diff_ar", "wkly_rw"])
    latent_model = filter(lm -> occursin(lm, filename), latent_namemodels)[1]
end

"""
Internal method to get the true GI mean from a filename.
"""
function _get_true_gi_mean_from_filename(filename;
        truth_gi_mean_strings::Vector{String} = "truth_gi_mean_" .*
                                                string.([2.0, 10.0, 20.0]))
    true_gi = filter(tgi -> occursin(tgi, filename), truth_gi_mean_strings)[1] |>
              str -> split(str, "_")[end] |> s -> parse(Float64, s)
end

"""
Internal method to get the used GI mean from a filename.
"""
function _get_used_gi_mean_from_filename(filename;
        used_gi_mean_strings::Vector{String} = "_gi_mean_" .*
                                               string.([2.0, 10.0, 20.0]) .* "_gi_std")
    used_gi = filter(ugi -> occursin(ugi, filename), used_gi_mean_strings)[1] |>
              str -> split(str, "_")[end] |> s -> parse(Float64, s)
end


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
    filename, output, epi_datas; qs = [0.025, 0.5, 0.975])
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

preds = map(used_epi_datas) do epi_data
    generate_quantiles_for_targets(output, epi_data, qs)
end

used_gi_means = igp_model == "Renewal" ?
                [EpiAwarePipeline._get_used_gi_mean_from_filename(filename)] :
                make_gi_params(EpiAwareExamplePipeline())["gi_means"]

#Create the dataframe columnwise
df = mapreduce(vcat, preds, used_gi_means) do pred, used_gi_mean
    mapreduce(vcat, keys(pred)) do target
        target_mat = pred[target]
        target_times = collect(1:size(target_mat, 1)) .+ (inference_config.tspan[1] - 1)
        _df = DataFrame(target_time = target_times)
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
end
