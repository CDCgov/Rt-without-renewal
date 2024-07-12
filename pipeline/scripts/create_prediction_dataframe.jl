using Pkg
Pkg.activate(joinpath(@__DIR__(), ".."))

using EpiAwarePipeline, EpiAware, AlgebraOfGraphics, JLD2, DrWatson, Plots, DataFramesMeta,
      Statistics, Distributions, DrWatson

## load some data and create a dataframe for the plot
files = readdir(datadir("epiaware_observables")) |>
        strs -> filter(s -> occursin("jld2", s), strs)

##
pipelines = [
    SmoothOutbreakPipeline(), MeasuresOutbreakPipeline(),
    SmoothEndemicPipeline(), RoughEndemicPipeline()]


prediction_df = mapreduce(vcat, files) do filename
    output = load(joinpath(datadir("epiaware_observables"), filename))
    make_prediction_dataframe_from_output(filename, output, epi_datas, pipelines)
end

CSV.write(plotsdir("analysis_df.csv"), prediction_df)
