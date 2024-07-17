# Overview: This fig aims at presenting the nowcasting (e.g. 0 horizon estimate)
# at rolling inference time points for each scenario with each inference model choice
# and possible misspecification of generation interval. Time horizon choice: Chosen
# horizon = 0 to align with Fig 1 but with other horizons as SI plots. Plotting details: 3 x 4 = 12 rows
# corresponding to 4 main scenarios (e.g. outbreak with measures etc.) and 3 main targets
# (e.g. exponential growth rate etc), the scenario GI is fixed to the middle mean GI (10 days; others are in SI)
# and 3 columns corresponding to underestimating mean GI (left), good estimation
# of GI (middle) and over estimating mean GI (right). Actual values as scatter plot.
# The posterior inferred value at the estimation date are plotted as boxplot plot
# quantiles1 with colour determining the inference model.

## Script to make figure 1 and alternate latent models for SI
using Pkg
Pkg.activate(joinpath(@__DIR__(), ".."))

using EpiAwarePipeline, EpiAware, AlgebraOfGraphics, JLD2, DrWatson, Plots, DataFramesMeta,
      Statistics, Distributions, CSV

##
pipelines = [
    SmoothOutbreakPipeline(), MeasuresOutbreakPipeline(),
    SmoothEndemicPipeline(), RoughEndemicPipeline()]

## load some data and create a dataframe for the plot
truth_data_files = readdir(datadir("truth_data")) |>
                   strs -> filter(s -> occursin("jld2", s), strs)
analysis_df = CSV.File(plotsdir("analysis_df.csv")) |> DataFrame
truth_df = mapreduce(vcat, truth_data_files) do filename
    D = load(joinpath(datadir("truth_data"), filename))
    make_truthdata_dataframe(filename, D, pipelines)
end

# Define scenario titles and reference times for figure 2
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

##

idxs = [τ ∈ 0:6 for τ in analysis_df.Reference_Time .- analysis_df.target_times]
analysis_df.Reference_Time .- analysis_df.target_times .∈
df = analysis_df[idxs, :]

df2 = @subset(analysis_df, :Reference_Time .- :target_times .∈ fill(0:6, size(analysis_df, 1)))

model_plotting_data = analysis_df |>
                          df -> @subset(df, :True_GI_Mean.==10.) |>
                            df -> @subset(df, :Scenario.=="smooth_outbreak") |>
                                df -> @subset(df, :Reference_Time .- :target_times .∈ fill(0:6, size(df, 1)))

                                |>
                                                  data

##

function _figure_two_scenario(analysis_df, scenario; true_gi_choice,
    lower_sym = :q_025, upper_sym = :q_975)


    model_plotting_data = analysis_df |>
                          df -> @subset(df, :True_GI_Mean.==true_gi_choice) |>
                            df -> @subset(df, :Scenario.==scenario) |>
                                df -> @subset(df, :Reference_Time .- :target_times .∈ fill(0:6, size(df, 1))) |>
                                                  data

    plt_model = model_plotting_data *
                mapping(:target_times => "T", :q_5 => "Process values",
                    col = :Target, row = :IGP_Model => "IGP model",
                    color = :Latent_Model => "Latent model") *
                mapping(lower = lower_sym, upper = upper_sym) * visual(LinesFill)

    return plt_model
end

function figureone_with_latent_model(
        truth_df, analysis_df, scenario_dict; fig_kws = (; size = (1000, 2000)),
        true_gi_choice = 10.0, used_gi_choice = 10.0, legend_title = "Process type")
    # Perform checks on the dataframes
    _figure_one_dataframe_checks(truth_df, analysis_df, scenario_dict)
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

## `wkly_ar` is the default latent model which we show as figure 1, others are for SI

_ = map(latent_model_dict |> keys |> collect) do latent_model
    fig = figureone(
        truth_df, analysis_df, latent_model, scenario_dict, target_dict, latent_model_dict)
    save(plotsdir("figure1_$(latent_model).png"), fig)
end
