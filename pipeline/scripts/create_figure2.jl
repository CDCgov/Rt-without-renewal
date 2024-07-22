## Script to make figure 2 and alternate latent models for SI
using Pkg
Pkg.activate(joinpath(@__DIR__(), ".."))

using EpiAwarePipeline, EpiAware, AlgebraOfGraphics, JLD2, DrWatson, DataFramesMeta,
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
    D = JLD2.load(joinpath(datadir("truth_data"), filename))
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
    "log_I_t" => (title = "log(Incidence)", ylims = (3.5, 6), ord = 1),
    "rt" => (title = "Exp. growth rate", ylims = (-0.1, 0.1), ord = 2),
    "Rt" => (title = "Reproductive number", ylims = (-0.1, 3), ord = 3)
)

latent_model_dict = Dict(
    "wkly_rw" => (title = "Random walk",),
    "wkly_ar" => (title = "AR(1)",),
    "wkly_diff_ar" => (title = "Diff. AR(1)",)
)

##

fig = figuretwo(
    truth_df, analysis_df, "Renewal", scenario_dict, target_dict)
_ = map(analysis_df.IGP_Model |> unique) do igp
    fig = figureone(
        truth_df, analysis_df, latent_model, scenario_dict, target_dict, latent_model_dict)
    save(plotsdir("figure2_$(igp).png"), fig)
end
