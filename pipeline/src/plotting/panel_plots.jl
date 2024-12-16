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
        ax, pred; igps = ["DirectInfections", "ExpGrowthRate", "Renewal"],
        colors = [:red, :blue, :green], iqr_alpha = 0.3)
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
function _plot_truth!(ax, truth; color = :black)
    x = truth[!, "target_times"]
    y = truth[!, "target_values"]
    scatter!(ax, x, y, color = color, label = "Data")

    return nothing
end

"""
Filter the `truth` DataFrame for `scenario`, `target`, `latent_model`, `true_gi_choice`,
    and `used_gi_choice`. This is aimed at generating facets for figure 1.
"""
function _fig_truth_filter(truth, scenario, target; true_gi_choice)
    df = truth |>
         df -> @subset(df, :True_GI_Mean.==true_gi_choice) |>
               df -> @subset(df, :Scenario.==scenario) |>
                     df -> @subset(df, :Target.==target)
    return df
end
