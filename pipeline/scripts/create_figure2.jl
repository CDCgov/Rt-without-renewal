using EpiAwarePipeline, EpiAware, AlgebraOfGraphics, JLD2, DrWatson, DataFramesMeta,
      Statistics, Distributions, CSV, CairoMakie

## Define scenarios and targets
scenarios = ["measures_outbreak", "smooth_outbreak", "smooth_endemic", "rough_endemic"]
targets = ["log_I_t", "rt", "Rt"]
gi_means = [2.0, 10.0, 20.0]

## load some data and create a dataframe for the plot
truth_data_df = CSV.File(plotsdir("plotting_data/truthdata.csv")) |> DataFrame
prediction_df = CSV.File(plotsdir("plotting_data/predictions.csv")) |> DataFrame

# Define scenario titles and reference times for figure 1
scenario_dict = Dict(
    "measures_outbreak" => (title = "Outbreak with measures", T = 28),
    "smooth_outbreak" => (title = "Outbreak no measures", T = 35),
    "smooth_endemic" => (title = "Smooth endemic", T = 35),
    "rough_endemic" => (title = "Rough endemic", T = 35)
)

target_dict = Dict(
    "log_I_t" => (title = "log(Incidence)",),
    "rt" => (title = "Exp. growth rate",),
    "Rt" => (title = "Reproductive number",)
)

latent_model_dict = Dict(
    "rw" => (title = "Random walk",),
    "ar" => (title = "AR(1)",),
    "diff_ar" => (title = "Diff. AR(1)",)
)

##
# **Fig 2**: _Overview_: This fig aims at presenting the nowcasting (e.g. 0 horizon estimate)
# at rolling inference time points for each scenario with each inference model choice _and_
# possible misspecification of generation interval. Time horizon choice: Chosen horizon = 0
# to align with Fig 1 but with other horizons as SI plots. _Plotting details:_ 3 x 4 = 12 rows
# corresponding to 4 main scenarios (e.g. outbreak with measures etc.) and 3 main targets (e.g.
# exponential growth rate etc), the scenario GI is fixed to the middle mean GI (10 days;
# others are in SI) and 3 columns corresponding to _underestimating mean GI_ (left), good
# estimation of GI (middle) and over estimating mean GI (right). Actual values as scatter plot.
# The posterior inferred value at the estimation date_ are plotted as boxplot plot quantiles
# with colour determining the inference model.

df = EpiAwarePipeline._fig2_pred_filter(prediction_df, "smooth_outbreak", "log_I_t", "ar",
    0; true_gi_choice = 10.0, used_gi_choice = 10.0)
truth_df = EpiAwarePipeline._fig_truth_filter(
    truth_data_df, "smooth_outbreak", "log_I_t"; true_gi_choice = 10.0)
fig = Figure()
ax = Axis(fig[1, 1])
EpiAwarePipeline._plot_predictions!(
    ax, df; igps = ["DirectInfections", "ExpGrowthRate", "Renewal"],
    colors = [:red, :blue, :green], iqr_alpha = 0.3)
EpiAwarePipeline._plot_truth!(ax, truth_df; color = :black)
vlines!(ax, df.Reference_Time |> unique, color = :black, linestyle = :dash)
ax.limits = ((minimum(df.Reference_Time) - 7, maximum(df.Reference_Time) + 1), nothing)
ax.xticks = vcat(minimum(df.Reference_Time) - 7, df.Reference_Time |> unique)
fig

# figs = mapreduce(vcat, scenarios) do scenario
#     mapreduce(gi_means) do true_gi_choice
#         fig = figuretwo(
#             truth_data_df, prediction_df, "ar", scenario_dict, target_dict;
#             true_gi_choice = true_gi_choice)
#         save(plotsdir("figure2_$(scenario)_trueGI_$(true_gi_choice).png"), fig)
#     end
# end

##

## `ar` is the default latent model which we show as figure 1, others are for SI

figs = mapreduce(vcat, latent_model_dict |> keys |> collect) do latent_model
    fig = figuretwo(
        prediction_df, truth_data_df, scenarios, targets, 0;
        scenario_dict, target_dict, latent_model_dict,
        latent_model, igps = ["DirectInfections", "ExpGrowthRate", "Renewal"],
        true_gi_choice = 10.0, other_gi_choices = [2.0, 10.0, 20.0], data_color = :black,
        colors = [:red, :blue, :green], iqr_alpha = 0.3, horizon_diff = 7)

    save(
        plotsdir("figure2_$(latent_model).png"),
        fig)
end
