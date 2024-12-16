"""
Filter the `predictions` DataFrame for `scenario`, `target`, `reference_time`,
    `latent_model`, `true_gi_choice`, and `used_gi_choice`. This is aimed at generating
    facets for figure 1.
"""
function _fig1_pred_filter(predictions, scenario, target, reference_time,
        latent_model; true_gi_choice = 2.0, used_gi_choice = 2.0)
    df = predictions |>
         df -> @subset(df, :Latent_Model.==latent_model) |>
               df -> @subset(df, :True_GI_Mean.==true_gi_choice) |>
                     df -> @subset(df, :Used_GI_Mean.==used_gi_choice) |>
                           df -> @subset(df, :Reference_Time.==reference_time) |>
                                 df -> @subset(df, :Scenario.==scenario) |>
                                       df -> @subset(df, :Target.==target)
    return df
end

"""
Filter the `truth` DataFrame for `scenario`, `target`, `latent_model`, `true_gi_choice`,
    and `used_gi_choice`. This is aimed at generating facets for figure 1.
"""
function _fig1_truth_filter(truth, scenario, target; true_gi_choice)
    df = truth |>
         df -> @subset(df, :True_GI_Mean.==true_gi_choice) |>
               df -> @subset(df, :Scenario.==scenario) |>
                     df -> @subset(df, :Target.==target)
    return df
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
            #Filter the data for fig1 panels
            pred_df = _fig1_pred_filter(
                prediction_df, scenario, target, scenario_dict[scenario].T,
                latent_model; true_gi_choice, used_gi_choice)
            truth_df = _fig1_truth_filter(truth_data_df, scenario, target; true_gi_choice)
            #Plot onto axes
            _plot_predictions!(ax, pred_df; igps, colors, iqr_alpha)
            _plot_truth!(ax, truth_df; color = data_color)
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
