## Script to make figure 1
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

## Make mainfigure plots

# Define scenario titles and reference times for figure 1
scenario_dict = Dict(
    "measures_outbreak" => (title = "Outbreak with measures", T = 28),
    "smooth_outbreak" => (title = "Outbreak no measures", T = 35),
    "smooth_endemic" => (title = "Smooth endemic", T = 35),
    "rough_endemic" => (title = "Rough endemic", T = 35)
)

fig1 = figureone(truth_df, analysis_df, scenario_dict)

## Save the figure
save(plotsdir("figure1.png"), fig1)
