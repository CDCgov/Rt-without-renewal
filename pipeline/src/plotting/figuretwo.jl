function _make_captions!(df, scenario_dict, target_dict)
    scenario_titles = [scenario_dict[scenario].title for scenario in df.Scenario]
    target_titles = [target_dict[target].title for target in df.Target]
    df.Scenario_Target .= scenario_titles .* "\n" .* target_titles
    return nothing
end

function _figure_two_truth_data(
        truth_df, scenario_dict, target_dict; true_gi_choice, gi_choices = [
            2.0, 10.0, 20.0])
    _truth_df = mapreduce(vcat, gi_choices) do used_gi
        df = deepcopy(truth_df)
        df.Used_GI_Mean .= used_gi
        df
    end
    _make_captions!(_truth_df, scenario_dict, target_dict)

    truth_plotting_data = _truth_df |>
                          df -> @subset(df, :True_GI_Mean.==true_gi_choice) |>
                                df -> @transform(df, :Data="Truth data") |> data
    plt_truth = truth_plotting_data *
                mapping(:target_times => "T", :target_values => "Process values",
                    row = :Scenario_Target,
                    col = :Used_GI_Mean => renamer([2.0 => "Underestimate GI",
                        10.0 => "Good GI", 20.0 => "Overestimate GI"]),
                    color = :Data => AlgebraOfGraphics.scale(:color2)) *
                visual(AlgebraOfGraphics.Scatter)
    return plt_truth
end

function _figure_two_scenario(
        analysis_df, igp, scenario_dict, target_dict; true_gi_choice,
        lower_sym = :q_025, upper_sym = :q_975)
    min_ref_time = minimum(analysis_df.Reference_Time)
    early_df = analysis_df |>
               df -> @subset(df, :Reference_Time.==min_ref_time) |>
                     df -> @subset(df, :IGP_Model.==igp) |>
                           df -> @subset(df, :True_GI_Mean.==true_gi_choice) |>
                                 df -> @subset(df, :target_times.<=min_ref_time - 7)

    seqn_df = analysis_df |>
              df -> @subset(df, :True_GI_Mean.==true_gi_choice) |>
                    df -> @subset(df, :IGP_Model.==igp) |>
                          df -> @subset(df,
        :Reference_Time .- :target_times.∈fill(0:6, size(df, 1)))

    full_df = vcat(early_df, seqn_df)
    _make_captions!(full_df, scenario_dict, target_dict)

    model_plotting_data = full_df |> data

    plt_model = model_plotting_data *
                mapping(:target_times => "T", :q_5 => "Process values",
                    row = :Scenario_Target,
                    col = :Used_GI_Mean => renamer([2.0 => "Underestimate GI",
                        10.0 => "Good GI", 20.0 => "Overestimate GI"]),
                    color = :Latent_Model => "Latent models") *
                mapping(lower = lower_sym, upper = upper_sym) *
                visual(LinesFill)

    return plt_model
end

function figuretwo(truth_df, analysis_df, igp, scenario_dict,
        target_dict; fig_kws = (; size = (1000, 2800)),
        true_gi_choice = 10.0, gi_choices = [2.0, 10.0, 20.0])

    # Perform checks on the dataframes
    _dataframe_checks(truth_df, analysis_df, scenario_dict)

    f_td = _figure_two_truth_data(
        truth_df, scenario_dict, target_dict; true_gi_choice, gi_choices)
    f_mdl = _figure_two_scenario(
        analysis_df, igp, scenario_dict, target_dict; true_gi_choice)

    fg = draw(f_mdl + f_td; facet = (; linkyaxes = :none),
        legend = (; orientation = :horizontal, position = :bottom),
        figure = fig_kws,
        axis = (; xlabel = "T", ylabel = "Process values"))
    for g in fg.grid[1:3:end, :]
        g.axis.limits = (nothing, target_dict["rt"].ylims)
    end
    for g in fg.grid[2:3:end, :]
        g.axis.limits = (nothing, target_dict["Rt"].ylims)
    end
    for g in fg.grid[3:3:end, :]
        g.axis.limits = (nothing, target_dict["log_I_t"].ylims)
    end

    return fg
end
