function _fig2_pred_filter(predictions, scenario, target, latent_model, horizon;
        true_gi_choice, used_gi_choice, horizon_diff = 7)
    df = predictions |>
         df -> @subset(df, :Latent_Model.==latent_model) |>
               df -> @subset(df, :True_GI_Mean.==true_gi_choice) |>
                     df -> @subset(df, :Used_GI_Mean.==used_gi_choice) |>
                           df -> @subset(df,
        horizon-horizon_diff.<(:target_times.-:Reference_Time).<=horizon) |>
                                 df -> @subset(df, :Scenario.==scenario) |>
                                       df -> @subset(df, :Target.==target)
    return df
end

function figuretwo(
        prediction_df, truth_data_df, scenarios, targets, horizon;
        scenario_dict, target_dict, latent_model_dict,
        latent_model = "ar", igps = ["DirectInfections", "ExpGrowthRate", "Renewal"],
        true_gi_choice = 10.0, other_gi_choices = [2.0, 10.0, 20.0], data_color = :black,
        colors = [:red, :blue, :green], iqr_alpha = 0.3, horizon_diff = 7)
    fig = Figure(; size = (1000, 800 * length(scenarios)))
    axs = mapreduce(vcat, enumerate(scenarios)) do (i, scenario)
        n = length(targets)
        Label(fig[(n * (i - 1) + 1):(n * i), 0],
            scenario_dict[scenario].title, rotation = pi / 2, fontsize = 36)
        mapreduce(hcat, enumerate(targets)) do (j, target)
            map(enumerate(other_gi_choices)) do (k, used_gi_choice)
                row = j + (i - 1) * length(targets)
                ax = Axis(fig[row, k])
                # #Filter the data for fig2 panels
                pred_df = _fig2_pred_filter(
                    prediction_df, scenario, target, latent_model, horizon;
                    true_gi_choice, used_gi_choice, horizon_diff)
                truth_df = _fig_truth_filter(
                    truth_data_df, scenario, target; true_gi_choice)
                # #Plot onto axes
                _plot_predictions!(ax, pred_df; igps, colors, iqr_alpha)
                _plot_truth!(ax, truth_df; color = data_color)
                vlines!(ax, pred_df.Reference_Time |> unique, color = :black,
                    linestyle = :dash, label = "Reference time")
                # axes
                if row == 1
                    if k == 1
                        ax.title = "Underestimating mean GI"
                    elseif k == 2
                        ax.title = "Good estimation of GI"
                    elseif k == 3
                        ax.title = "Overestimating mean GI"
                    end
                end
                if row == length(targets) * length(scenarios)
                    ax.xlabel = "Time"
                end
                if k == 1
                    ax.ylabel = target_dict[target].title
                end
                ax.limits = (
                    (minimum(pred_df.Reference_Time) - horizon_diff,
                        maximum(pred_df.Reference_Time) + 1),
                    nothing)
                ax.xticks = vcat(minimum(pred_df.Reference_Time) - horizon_diff,
                    pred_df.Reference_Time |> unique)
                ax
            end
        end
    end
    leg = Legend(fig[length(targets) * length(scenarios) + 1, 1:2],
        last(axs), "Infection generating process";
        orientation = :horizontal, tellwidth = false, framevisible = false)
    lab = Label(fig[length(targets) * length(scenarios) + 1, length(other_gi_choices)],
        "Latent model for \n infection generating\n process: $(latent_model_dict[latent_model].title) \n True mean GI: $(true_gi_choice) days \n Horizon: $(horizon) days";
        tellwidth = false,
        fontsize = 18)
    resize_to_layout!(fig)
    fig
end
