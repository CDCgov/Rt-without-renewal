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

## `ar` is the default latent model which we show as figure 1, others are for SI

figs = mapreduce(vcat, latent_model_dict |> keys |> collect) do latent_model
    map(Iterators.product(gi_means, gi_means)) do (true_gi_choice, used_gi_choice)
        fig = figureone(
            prediction_df, truth_data_df, scenarios, targets; scenario_dict, target_dict,
            latent_model_dict, latent_model, true_gi_choice, used_gi_choice)
        # save(plotsdir("figure1_$(latent_model).png"), fig)
        save(
            plotsdir("figure1_$(latent_model)_trueGI_$(true_gi_choice)_usedGI_$(used_gi_choice).png"),
            fig)
    end
end
