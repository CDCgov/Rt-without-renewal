"""
Internal method to check if the required columns are present in the truth dataframe.

# Arguments
- `truth_df`: The truth dataframe to be checked.

"""
function _figure_one_truth_dataframe_checks(truth_df)
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
function _figure_one_analysis_dataframe_checks(analysis_df)
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
function _figure_one_dataframe_checks(truth_df, analysis_df, scenario_dict)
    @assert issetequal(unique(truth_df.Scenario), unique(analysis_df.Scenario)) "Truth and analysis data scenarios do not match"
    @assert issetequal(unique(truth_df.Scenario), keys(scenario_dict)) "Truth and analysis data True_GI_Mean do not match"
    _figure_one_truth_dataframe_checks(truth_df)
    _figure_one_analysis_dataframe_checks(analysis_df)
end

"""
Internal method for creating a figure of model inference for a specific scenario
    using the given analysis data.

# Arguments
- `analysis_df`: The analysis data frame.
- `scenario`: The scenario to plot.
- `reference_time`: The reference time.
- `true_gi_choice`: The true GI choice.
- `used_gi_choice`: The used GI choice.
- `lower_sym`: The symbol for the lower quantile (default is `:q_025`).
- `upper_sym`: The symbol for the upper quantile (default is `:q_975`).

# Returns
- `plt_model`: The plot object.

"""
function _figure_one_scenario(analysis_df, scenario; reference_time, true_gi_choice,
        used_gi_choice, lower_sym = :q_025, upper_sym = :q_975)
    model_plotting_data = analysis_df |>
                          df -> @subset(df, :True_GI_Mean.==true_gi_choice) |>
                                df -> @subset(df, :Used_GI_Mean.==used_gi_choice) |>
                                      df -> @subset(df, :Reference_Time.==reference_time) |>
                                            df -> @subset(df, :Scenario.==scenario) |>
                                                  data

    plt_model = model_plotting_data *
                mapping(:target_times => "T", :q_5 => "Process values",
                    col = :Target, row = :IGP_Model => "IGP model",
                    color = :Latent_Model => "Latent model") *
                mapping(lower = lower_sym, upper = upper_sym) * visual(LinesFill)

    return plt_model
end

"""
Internal method that generates a plot of the truth data for a specific scenario.

## Arguments
- `truth_df`: The truth data DataFrame.
- `scenario`: The scenario for which the truth data should be plotted.
- `true_gi_choice`: The choice of true GI mean.

## Returns
- `plt_truth`: The plot of the truth data.

"""
function _figure_one_scenario_truth_data(truth_df, scenario; true_gi_choice)
    truth_plotting_data = truth_df |>
                          df -> @subset(df, :True_GI_Mean.==true_gi_choice) |>
                                df -> @subset(df, :Scenario.==scenario) |> data
    plt_truth = truth_plotting_data *
                mapping(:target_times => "T", :target_values => "values",
                    col = :Target, color = :Latent_Model) *
                visual(Lines)
    return plt_truth
end

"""
Generate figure 1 showing the analysis and truth data for different scenarios.

## Arguments
- `truth_df`: DataFrame containing the truth data.
- `analysis_df`: DataFrame containing the analysis data.
- `scenario_dict`: Dictionary containing information about the scenarios.

## Keyword Arguments
- `fig_kws`: Keyword arguments for the Figure object. Default is `(; size = (1000, 2000))`.
- `true_gi_choice`: Value for the true generation interval choice. Default is `10.0`.
- `used_gi_choice`: Value for the used generation interval choice. Default is `10.0`.
- `legend_title`: Title for the legend. Default is `"Process type"`.

## Returns
- `fig`: Figure object containing the generated figure.

"""
function figureone(
        truth_df, analysis_df, scenario_dict; fig_kws = (; size = (1000, 2000)),
        true_gi_choice = 10.0, used_gi_choice = 10.0, legend_title = "Process type")
    # Perform checks on the dataframes
    _figure_one_dataframe_checks(truth_df, analysis_df, scenario_dict)
    # Treat the truth data as a Latent model option
    truth_df[!, "Latent_Model"] .= "Truth data"

    scenarios = analysis_df.Scenario |> unique
    plt_truth_vect = map(scenarios) do scenario
        _figure_one_scenario_truth_data(truth_df, scenario; true_gi_choice)
    end
    plt_analysis_vect = map(scenarios) do scenario
        _figure_one_scenario(
            analysis_df, scenario; reference_time = scenario_dict[scenario].T,
            true_gi_choice, used_gi_choice)
    end

    fig = Figure(; fig_kws...)
    leg = nothing
    for (i, scenario) in enumerate(scenarios)
        sf = fig[i, :]
        ag = draw!(
            sf, plt_analysis_vect[i] + plt_truth_vect[i], facet = (; linkyaxes = :none))
        leg = AlgebraOfGraphics.compute_legend(ag)
        Label(sf[0, :], scenario_dict[scenario].title, fontsize = 24, font = :bold)
    end

    Label(fig[:, 0], "Process values", fontsize = 28, font = :bold, rotation = pi / 2)
    Label(fig[:, 2], "Infection generating process",
        fontsize = 24, font = :bold, rotation = -pi / 2)
    _leg = (leg[1], leg[2], [legend_title])
    Legend(fig[:, 3], _leg...)

    return fig
end
