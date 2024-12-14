using EpiAwarePipeline, EpiAware, AlgebraOfGraphics, JLD2, DrWatson, DataFramesMeta,
      Statistics, Distributions, CSV, CairoMakie

## Define scenarios
scenarios = ["measures_outbreak", "smooth_outbreak", "smooth_endemic", "rough_endemic"]

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
    "log_I_t" => (title = "log(Incidence)", ylims = (3.5, 12)),
    "rt" => (title = "Exp. growth rate", ylims = (-0.5, 0.5)),
    "Rt" => (title = "Reproductive number", ylims = (-0.1, 2.5))
)

latent_model_dict = Dict(
    "rw" => (title = "Random walk",),
    "ar" => (title = "AR(1)",),
    "diff_ar" => (title = "Diff. AR(1)",)
)

##
targets = ["log_I_t", "rt", "Rt"]
plt_truth_mat = [EpiAwarePipeline._figure_one_truth_data_panel(
                     truth_data_df, scenario, target; true_gi_choice = 2.0)
                 for scenario in keys(scenario_dict), target in targets]

## `ar` is the default latent model which we show as figure 1, others are for SI

_ = map(latent_model_dict |> keys |> collect) do latent_model
    fig = figureone(
        truth_data_df, prediction_df, latent_model, scenario_dict, target_dict, latent_model_dict)
    save(plotsdir("figure1_$(latent_model).png"), fig)
end
