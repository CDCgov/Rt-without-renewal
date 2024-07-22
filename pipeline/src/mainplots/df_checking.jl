"""
Internal method to check if the required columns are present in the truth dataframe.

# Arguments
- `truth_df`: The truth dataframe to be checked.

"""
function _truth_dataframe_checks(truth_df)
    @assert "True_GI_Mean" ∈ names(truth_df) "True_GI_Mean col not in truth data"
    @assert "Scenario" ∈ names(truth_df) "Scenario col not in truth data"
    @assert "target_times" ∈ names(truth_df) "target_times col not in truth data"
    @assert "target_values" ∈ names(truth_df) "target_values col not in truth data"
end

"""
Internal method to perform checks on the analysis dataframe to ensure that it contains the required columns.

# Arguments
- `analysis_df`: The analysis dataframe to be checked.

# Raises
- `AssertionError`: If any of the required columns are missing in the analysis dataframe.

"""
function _analysis_dataframe_checks(analysis_df)
    @assert "True_GI_Mean" ∈ names(analysis_df) "True_GI_Mean col not in analysis data"
    @assert "Used_GI_Mean" ∈ names(analysis_df) "Used_GI_Mean col not in analysis data"
    @assert "Reference_Time" ∈ names(analysis_df) "Reference_Time col not in analysis data"
    @assert "Scenario" ∈ names(analysis_df) "Scenario col not in analysis data"
    @assert "IGP_Model" ∈ names(analysis_df) "IGP_Model col not in analysis data"
    @assert "Latent_Model" ∈ names(analysis_df) "Latent_Model col not in analysis data"
    @assert "target_times" ∈ names(analysis_df) "target_times col not in analysis data"
end

"""
Internal method to perform checks on the truth and analysis dataframes for Figure One.

# Arguments
- `truth_df::DataFrame`: The truth dataframe.
- `analysis_df::DataFrame`: The analysis dataframe.
- `scenario_dict::Dict{String, Any}`: A dictionary containing scenario information.

# Raises
- `AssertionError`: If the scenarios in the truth and analysis dataframes do not match, or if the scenarios in the truth dataframe do not match the keys in the scenario dictionary.

"""
function _dataframe_checks(truth_df, analysis_df, scenario_dict)
    @assert issetequal(unique(truth_df.Scenario), unique(analysis_df.Scenario)) "Truth and analysis data scenarios do not match"
    @assert issetequal(unique(truth_df.Scenario), keys(scenario_dict)) "Truth and analysis data True_GI_Mean do not match"
    _truth_dataframe_checks(truth_df)
    _analysis_dataframe_checks(analysis_df)
end
