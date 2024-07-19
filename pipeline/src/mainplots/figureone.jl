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
function _figure_scenario_truth_data(truth_df, scenario; true_gi_choice)
    truth_plotting_data = truth_df |>
                          df -> @subset(df, :True_GI_Mean.==true_gi_choice) |>
                                df -> @subset(df, :Scenario.==scenario) |> data
    plt_truth = truth_plotting_data *
                mapping(:target_times => "T", :target_values => "values",
                    col = :Target, color = :Latent_Model => "Latent Model") *
                visual(Lines)
    return plt_truth
end

"""
Generate a version figure 1 showing the analysis and truth data for different scenarios _and_
different latent process models.

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
function figureone_with_latent_model(
        truth_df, analysis_df, scenario_dict; fig_kws = (; size = (1000, 2000)),
        true_gi_choice = 10.0, used_gi_choice = 10.0, legend_title = "Process type")
    # Perform checks on the dataframes
    _dataframe_checks(truth_df, analysis_df, scenario_dict)
    # Treat the truth data as a Latent model option
    truth_df[!, "Latent_Model"] .= "Truth data"

    scenarios = analysis_df.Scenario |> unique
    plt_truth_vect = map(scenarios) do scenario
        _figure_scenario_truth_data(truth_df, scenario; true_gi_choice)
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

"""
Internal method for creating a model panel plot for Figure One.

This function takes in various parameters to filter the `analysis_df` DataFrame and create a model panel plot for Figure One.
The filtered DataFrame is used to generate the plot using the `model_plotting_data` variable.
The plot includes process values, color-coded by the infection generating process,
and credible intervals defined by `lower_sym` and `upper_sym`.

## Arguments
- `analysis_df`: The DataFrame containing the analysis data.
- `scenario`: The scenario to filter the DataFrame.
- `target`: The target to filter the DataFrame.
- `latentmodel`: The latent model to filter the DataFrame.
- `reference_time`: The reference time to filter the DataFrame.
- `true_gi_choice`: The true GI mean value to filter the DataFrame.
- `used_gi_choice`: The used GI mean value to filter the DataFrame.
- `lower_sym`: The symbol representing the lower confidence interval (default: `:q_025`).
- `upper_sym`: The symbol representing the upper confidence interval (default: `:q_975`).

## Returns
- `plt_model`: The model panel plot.

"""
function _figure_one_model_panel(
        analysis_df, scenario, target, latentmodel; reference_time, true_gi_choice,
        used_gi_choice, lower_sym = :q_025, upper_sym = :q_975)
    model_plotting_data = analysis_df |>
                          df -> @subset(df, :True_GI_Mean.==true_gi_choice) |>
                                df -> @subset(df, :Used_GI_Mean.==used_gi_choice) |>
                                      df -> @subset(df, :Reference_Time.==reference_time) |>
                                            df -> @subset(df, :Scenario.==scenario) |>
                                                  df -> @subset(df, :Target.==target) |>
                                                        df -> @subset(df,
        :Latent_Model.==latentmodel) |>
                                                              data

    plt_model = model_plotting_data *
                mapping(:target_times => "T", :q_5 => "Process values",
                    color = :IGP_Model => "Infection generating process") *
                mapping(lower = lower_sym, upper = upper_sym) * visual(LinesFill)

    return plt_model
end

"""
Internal method for creating a truth data panel plot for a given scenario and
    target using the provided truth data.

## Arguments
- `truth_df`: DataFrame containing the truth data.
- `scenario`: Scenario to plot.
- `target`: Target to plot.
- `true_gi_choice`: True GI choice to filter the data.

## Returns
- `plt_truth`: Plot object representing the truth data panel.

"""
function _figure_one_truth_data_panel(truth_df, scenario, target; true_gi_choice)
    truth_plotting_data = truth_df |>
                          df -> @subset(df, :True_GI_Mean.==true_gi_choice) |>
                                df -> @subset(df, :Scenario.==scenario) |>
                                      df -> @subset(df, :Target.==target) |> data
    plt_truth = truth_plotting_data *
                mapping(
                    :target_times => "T", :target_values => "values", color = :IGP_Model) *
                visual(Scatter)
    return plt_truth
end

"""
Create figure one with multiple panels showing the analysis results and truth data for different scenarios and targets.

# Arguments
- `truth_df::DataFrame`: The truth data as a DataFrame.
- `analysis_df::DataFrame`: The analysis data as a DataFrame.
- `latent_model::AbstractString`: The latent model to use for the infection generating process.
- `scenario_dict::Dict{AbstractString, Scenario}`: A dictionary mapping scenario names to Scenario objects.
- `target_dict::Dict{AbstractString, Target}`: A dictionary mapping target names to Target objects.
- `latent_model_dict::Dict{AbstractString, LatentModel}`: A dictionary mapping latent model names to LatentModel objects.

# Optional Arguments
- `fig_kws::NamedTuple`: Keyword arguments for the Figure object.
- `true_gi_choice::Float64`: The true value of the infection generating process.
- `used_gi_choice::Float64`: The value of the infection generating process used in the analysis.
- `legend_title::AbstractString`: The title of the legend.
- `targets::Vector{AbstractString}`: The names of the targets to include in the figure.
- `scenarios::Vector{AbstractString}`: The names of the scenarios to include in the figure.

# Returns
- `fig::Figure`: The figure object containing the panels.

# Example
This assumes that the user already has the necessary dataframes `truth_df` and `analysis_df` loaded.

```julia
using EpiAwarePipeline
# Define scenario titles and reference times for figure 1
scenario_dict = Dict(
    "measures_outbreak" => (title = "Outbreak with measures", T = 28),
    "smooth_outbreak" => (title = "Outbreak no measures", T = 35),
    "smooth_endemic" => (title = "Smooth endemic", T = 35),
    "rough_endemic" => (title = "Rough endemic", T = 35)
)

target_dict = Dict(
    "log_I_t" => (title = "log(Incidence)", ylims = (3.5, 6)),
    "rt" => (title = "Exp. growth rate", ylims = (-0.1, 0.1)),
    "Rt" => (title = "Reproductive number", ylims = (-0.1, 3))
)

latent_model_dict = Dict(
    "wkly_rw" => (title = "Random walk",),
    "wkly_ar" => (title = "AR(1)",),
    "wkly_diff_ar" => (title = "Diff. AR(1)",)
)

fig1 = figureone(
    truth_df, analysis_df, "wkly_ar", scenario_dict, target_dict, latent_model_dict)
```

"""
function figureone(
        truth_df, analysis_df, latent_model, scenario_dict, target_dict,
        latent_model_dict; fig_kws = (; size = (1000, 1500)),
        true_gi_choice = 10.0, used_gi_choice = 10.0,
        legend_title = "Infection generating\n process",
        targets = ["log_I_t", "rt", "Rt"],
        scenarios = [
            "measures_outbreak", "smooth_outbreak", "smooth_endemic", "rough_endemic"])
    # Perform checks on the dataframes
    _dataframe_checks(truth_df, analysis_df, scenario_dict)
    latent_models = analysis_df.Latent_Model |> unique
    @assert latent_model in latent_models "The latent model is not in the analysis data"
    @assert latent_model in keys(latent_model_dict) "The latent model is not in the latent_model_dict dictionary"
    @assert all([target in keys(target_dict) for target in targets]) "Not all targets are in the target dictionary"
    @assert all([scenario in keys(scenario_dict) for scenario in scenarios]) "Not all scenarios are in the scenario dictionary"

    # Treat the truth data as a Latent model option
    truth_df[!, "IGP_Model"] .= "Truth data"

    plt_truth_mat = [_figure_one_truth_data_panel(
                         truth_df, scenario, target; true_gi_choice)
                     for scenario in keys(scenario_dict), target in targets]

    plt_analysis_mat = [_figure_one_model_panel(
                            analysis_df, scenario, target, latent_model;
                            reference_time = scenario_dict[scenario].T,
                            true_gi_choice, used_gi_choice)
                        for scenario in keys(scenario_dict), target in targets]

    fig = Figure(; fig_kws...)
    leg = nothing
    for (i, scenario) in enumerate(scenarios)
        for (j, target) in enumerate(targets)
            sf = fig[i, j]
            V = mapping([scenario_dict[scenario].T]) *
                visual(VLines, color = :red, linewidth = 3)

            ag = draw!(
                sf, plt_analysis_mat[i, j] + plt_truth_mat[i, j] + V,
                axis = (; limits = (nothing, target_dict[target].ylims)))
            # leg = AlgebraOfGraphics.compute_legend(ag)
            i == 1 &&
                Label(sf[0, 1], target_dict[target].title, fontsize = 22, font = :bold)
            j == 3 && Label(sf[1, 2], scenario_dict[scenario].title,
                fontsize = 18, font = :bold, rotation = -pi / 2)
        end
    end

    Label(fig[:, 0], "Process values", fontsize = 28, font = :bold, rotation = pi / 2)
    Label(fig[5, 3],
        "Latent model\n for infection\n generating\n process:\n$(latent_model_dict[latent_model].title)",
        fontsize = 18,
        font = :bold)
    # _leg = (leg[1], leg[2], [legend_title])
    # Legend(fig[5, 2], _leg...)
    resize_to_layout!(fig)
    return fig
end
