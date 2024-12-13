"""
Create a DataFrame containing truth data for analysis.

# Arguments
- `truth_data`: A dictionary containing truth data.
- `scenario`: Name of the truth data scenario.

# Returns
- `df::DataFrame`: A DataFrame containing the summarised truth data.

"""
function make_truthdata_dataframe(truth_data::Dict, scenario::String)
    I_t = truth_data["I_t"]
    I_0 = truth_data["truth_I0"]
    true_mean_gi = truth_data["truth_gi_mean"]
    log_It = _calc_log_infections(I_t)
    rt = _calc_rt(I_t, I_0)
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
