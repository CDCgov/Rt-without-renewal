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

# Define scenario titles and reference times for figure 1
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

## `wkly_ar` is the default latent model which we show as figure 1, others are for SI

_ = map(latent_model_dict |> keys |> collect) do latent_model
    fig = figureone(
        truth_df, analysis_df, latent_model, scenario_dict, target_dict, latent_model_dict)
    save(plotsdir("figure1_$(latent_model).png"), fig)
end
