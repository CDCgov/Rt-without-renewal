
"""
    make_truthdata_dataframe(filename, truth_data, pipelines; I_0 = 100.0)

Create a DataFrame containing truth data for analysis.

# Arguments
- `filename::String`: The name of the file.
- `truth_data::Dict`: A dictionary containing truth data.
- `pipelines::Array`: An array of pipelines.
- `I_0::Float64`: Initial value for I_t (default: 100.0).

# Returns
- `df::DataFrame`: A DataFrame containing the truth data.

"""
function make_truthdata_dataframe(filename, truth_data, pipelines; I_0 = 100.0)
    I_t = truth_data["I_t"]
    true_mean_gi = truth_data["truth_gi_mean"]
    log_It = _calc_log_infections(I_t)
    rt = _calc_rt(I_t, I_0)
    scenario = _get_scenario_from_filename(filename, pipelines)
    truth_procs = (; log_I_t = log_It, rt, Rt = truth_data["truth_process"])

    df = mapreduce(vcat, keys(truth_procs)) do target
        proc = truth_procs[target]
        _df = DataFrame(
            target_times = 1:length(proc),
            target_values = proc
        )
        _df[!, "Scenario"] .= scenario
        _df[!, "True_GI_Mean"] .= true_mean_gi
        _df[!, "Target"] .= string(target)
        return _df
    end

    return df
end
