"""
Plot predictions on the given axis (`ax`) based on the provided parameters.

# Arguments
- `ax`: The axis on which to plot the predictions.
- `predictions`: DataFrame containing the prediction data.
- `scenario`: The scenario to filter the predictions.
- `target`: The target to filter the predictions.
- `reference_time`: The reference time to filter the predictions.
- `latent_model`: The latent model to filter the predictions.
- `igps`: A list of IGP models to plot. Default is `["DirectInfections", "ExpGrowthRate", "Renewal"]`.
- `true_gi_choice`: The true generation interval mean to filter the predictions. Default is `2.0`.
- `used_gi_choice`: The used generation interval mean to filter the predictions. Default is `2.0`.
- `colors`: A list of colors for each IGP model. Default is `[:red, :blue, :green]`.
- `iqr_alpha`: The alpha value for the interquartile range bands. Default is `0.3`.

# Description
This function filters the `predictions` DataFrame based on the provided parameters and plots
    the predictions on the given axis (`ax`). It plots the median prediction line and two
    bands representing the interquartile range (IQR) and the 95% prediction interval for
    each IGP model specified in `igps`.

"""
function _plot_predictions!(
        ax, predictions, scenario, target, reference_time, latent_model;
        igps = ["DirectInfections", "ExpGrowthRate", "Renewal"],
        true_gi_choice = 2.0, used_gi_choice = 2.0, colors = [:red, :blue, :green],
        iqr_alpha = 0.3)
    pred = predictions |>
           df -> @subset(df, :Latent_Model.==latent_model) |>
                 df -> @subset(df, :True_GI_Mean.==true_gi_choice) |>
                       df -> @subset(df, :Used_GI_Mean.==used_gi_choice) |>
                             df -> @subset(df, :Reference_Time.==reference_time) |>
                                   df -> @subset(df, :Scenario.==scenario) |>
                                         df -> @subset(df, :Target.==target)
    for (c, igp) in zip(colors, igps)
        x = pred[pred.IGP_Model .== igp, "target_times"]
        y = pred[pred.IGP_Model .== igp, "q_5"]
        upr1 = pred[pred.IGP_Model .== igp, "q_75"]
        upr2 = pred[pred.IGP_Model .== igp, "q_975"]
        lwr1 = pred[pred.IGP_Model .== igp, "q_25"]
        lwr2 = pred[pred.IGP_Model .== igp, "q_025"]
        if length(x) > 0
            lines!(ax, x, y, color = c, label = igp, linewidth = 3)
            band!(ax, x, lwr1, upr1, color = (c, iqr_alpha))
            band!(ax, x, lwr2, upr2, color = (c, iqr_alpha / 2))
        end
    end
    return nothing
end

"""
Plot the truth data on the given axis.

# Arguments
- `ax`: The axis to plot on.
- `truth`: The DataFrame containing the truth data.
- `scenario`: The scenario to filter the truth data by.
- `target`: The target to filter the truth data by.
- `true_gi_choice`: The true generation interval choice to filter the truth data by (default is 2.0).
- `color`: The color of the scatter plot (default is :black).

"""
function _plot_truth!(ax, truth, scenario, target; true_gi_choice = 2.0, color = :black)
    pred = truth |>
           df -> @subset(df, :True_GI_Mean.==true_gi_choice) |>
                 df -> @subset(df, :Scenario.==scenario) |>
                       df -> @subset(df, :Target.==target)
    x = pred[!, "target_times"]
    y = pred[!, "target_values"]
    scatter!(ax, x, y, color = color, label = "Data")

    return nothing
end

"""
Generate a figure with multiple subplots showing predictions and truth data for different
    scenarios and targets.

# Arguments
- `prediction_df::DataFrame`: DataFrame containing prediction data.
- `truth_data_df::DataFrame`: DataFrame containing truth data.
- `scenarios::Vector{String}`: List of scenario names.
- `targets::Vector{String}`: List of target names.
- `scenario_dict::Dict{String, Scenario}`: Dictionary mapping scenario names to scenario objects.
- `target_dict::Dict{String, Target}`: Dictionary mapping target names to target objects.
- `latent_model_dict::Dict{String, LatentModel}`: Dictionary mapping latent model names to latent model objects.
- `latent_model::String`: Name of the latent model to use (default: "ar").
- `igps::Vector{String}`: List of infection generating processes (default: ["DirectInfections", "ExpGrowthRate", "Renewal"]).
- `true_gi_choice::Float64`: True generation interval choice (default: 2.0).
- `used_gi_choice::Float64`: Used generation interval choice (default: 2.0).
- `data_color::Symbol`: Color for the truth data (default: :black).
- `colors::Vector{Symbol}`: Colors for the predictions (default: [:red, :blue, :green]).
- `iqr_alpha::Float64`: Alpha value for the interquartile range shading (default: 0.3).

"""
function figureone(
        prediction_df, truth_data_df, scenarios, targets; scenario_dict, target_dict, latent_model_dict,
        latent_model = "ar", igps = ["DirectInfections", "ExpGrowthRate", "Renewal"],
        true_gi_choice = 2.0, used_gi_choice = 2.0, data_color = :black,
        colors = [:red, :blue, :green], iqr_alpha = 0.3)
    fig = Figure(; size = (1000, 800))
    axs = mapreduce(hcat, enumerate(targets)) do (i, target)
        map(enumerate(scenarios)) do (j, scenario)
            ax = Axis(fig[i, j])
            _plot_predictions!(
                ax, prediction_df, scenario, target, scenario_dict[scenario].T,
                latent_model; true_gi_choice, used_gi_choice, colors, iqr_alpha, igps)
            _plot_truth!(
                ax, truth_data_df, scenario, target; true_gi_choice, color = data_color)
            vlines!(ax, [scenario_dict[scenario].T], color = data_color,
                linewidth = 3, label = "Horizon")
            if i == 1
                ax.title = scenario_dict[scenario].title
            end
            if i == 3
                ax.xlabel = "Time"
            end
            if j == 1
                ax.ylabel = target_dict[target].title
            end
            ax
        end
    end

    leg = Legend(fig[length(targets) + 1, 1:3], last(axs), "Infection generating process";
        orientation = :horizontal, tellwidth = false, framevisible = false)
    lab = Label(fig[length(targets) + 1, length(scenarios)],
        "Latent model for \n infection generating\n process: $(latent_model_dict[latent_model].title)";
        tellwidth = false,
        fontsize = 18)
    resize_to_layout!(fig)
    fig
end
