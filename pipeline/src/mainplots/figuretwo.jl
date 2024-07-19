function _figure_two_truth_data(
        truth_df, scenario; true_gi_choice, gi_choices = [2.0, 10.0, 20.0])
    _truth_df = mapreduce(vcat, gi_choices) do used_gi
        df = deepcopy(truth_df)
        df.Used_GI_Mean .= used_gi
        df
    end

    truth_plotting_data = _truth_df |>
                          df -> @subset(df, :True_GI_Mean.==true_gi_choice) |>
                                df -> @subset(df, :Scenario.==scenario) |>
                                      df -> @transform(df, :Data="Truth data") |> data
    plt_truth = truth_plotting_data *
                mapping(:target_times => "T", :target_values => "Process values",
                    row = :Target => renamer(["log_I_t" => "log(Incidence)",
                        "rt" => "Exp. growth rate", "Rt" => "Reproductive number"]),
                    col = :Used_GI_Mean => renamer([2.0 => "Underestimate GI",
                        10.0 => "Good GI", 20.0 => "Overestimate GI"]),
                    color = :Data => AlgebraOfGraphics.scale(:color2)) *
                visual(AlgebraOfGraphics.Scatter)
    return plt_truth
end

function _figure_two_scenario(
        analysis_df, scenario, igp; true_gi_choice, lower_sym = :q_025, upper_sym = :q_975)
    min_ref_time = minimum(analysis_df.Reference_Time)
    early_df = analysis_df |>
               df -> @subset(df, :Reference_Time.==min_ref_time) |>
                     df -> @subset(df, :Scenario.==scenario) |>
                           df -> @subset(df, :IGP_Model.==igp) |>
                                 df -> @subset(df, :True_GI_Mean.==true_gi_choice) |>
                                       df -> @subset(df, :target_times.<=min_ref_time - 7)

    seqn_df = analysis_df |>
              df -> @subset(df, :True_GI_Mean.==true_gi_choice) |>
                    df -> @subset(df, :IGP_Model.==igp) |>
                          df -> @subset(df, :Scenario.==scenario) |>
                                df -> @subset(df,
        :Reference_Time .- :target_times.∈fill(0:6, size(df, 1)))

    model_plotting_data = vcat(early_df, seqn_df) |> data

    plt_model = model_plotting_data *
                mapping(:target_times => "T", :q_5 => "Process values",
                    row = :Target => renamer(["log_I_t" => "log(Incidence)",
                        "rt" => "Exp. growth rate", "Rt" => "Reproductive number"]),
                    col = :Used_GI_Mean => renamer([2.0 => "Underestimate GI",
                        10.0 => "Good GI", 20.0 => "Overestimate GI"]),
                    color = :Latent_Model => "Latent models") *
                mapping(lower = lower_sym, upper = upper_sym) *
                visual(LinesFill; title = "Scenario: " * scenario)

    return plt_model
end

function figuretwo(truth_df, analysis_df, igp, scenario_dict, target_dict,
    latent_model_dict; fig_kws = (; size = (1000, 1500)),
    true_gi_choice = 10.0, gi_choices = [2.0, 10.0, 20.0],
    scenarios = [
        "measures_outbreak", "smooth_outbreak", "smooth_endemic", "rough_endemic"])

     # Perform checks on the dataframes
    _dataframe_checks(truth_df, analysis_df, scenario_dict)
    latent_models = analysis_df.Latent_Model |> unique
    @assert all([scenario in keys(scenario_dict) for scenario in scenarios]) "Not all scenarios are in the scenario dictionary"

    # create the figure
    # fig = Figure(; fig_kws...)
    # for (i, scenario) in enumerate(scenarios)
    #     sub_fig = fig[i, :]
    #     f_td = _figure_two_truth_data(truth_df, scenario; true_gi_choice, gi_choices)
    #     f_mdl = _figure_two_scenario(analysis_df, scenario, igp; true_gi_choice)
    #     ag = draw!(sub_fig, f_td + f_mdl, scales();
    #         facet = (; linkyaxes = :none),
    #         )
    #     lg = (; orientation = :horizontal, position = :bottom)
    #     legend!(sub_fig; pairs(lg)...)
    #     Label(sub_fig[0, :], "Scenario: " * scenario_dict[scenario].title,
    #     fontsize = 18, font = :bold)
    # end

    subfigs = map(enumerate(scenarios)) do (i, scenario)
        f_td = _figure_two_truth_data(truth_df, scenario; true_gi_choice, gi_choices)
        f_mdl = _figure_two_scenario(analysis_df, scenario, igp; true_gi_choice)
        lg = (; orientation = :horizontal, position = :bottom)
        sf = draw(f_td + f_mdl; facet = (; linkyaxes = :none), legend = lg)
        Label(sf[0, :], "Scenario: " * scenario_dict[scenario].title,
        fontsize = 18, font = :bold)
    end


    return subfigs
end
