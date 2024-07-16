using Pkg
Pkg.activate(joinpath(@__DIR__(), ".."))

using EpiAwarePipeline, EpiAware, AlgebraOfGraphics, JLD2, DrWatson, Plots, DataFramesMeta,
      Statistics, Distributions, DrWatson

## load some data and create a dataframe for the plot
files = readdir(datadir("epiaware_observables")) |>
        strs -> filter(s -> occursin("jld2", s), strs)

## Define scenarios
pipelines = [
    SmoothOutbreakPipeline(), MeasuresOutbreakPipeline(),
    SmoothEndemicPipeline(), RoughEndemicPipeline()]

## Set up EpiData objects: Used in the prediction dataframe for infection generating
## processes that don't use directly in simulation.
gi_params = make_gi_params(pipelines[1])
epi_datas = map(gi_params["gi_means"]) do μ
    σ = gi_params["gi_stds"][1]
    shape = (μ / σ)^2
    scale = σ^2 / μ
    Gamma(shape, scale)
end .|> gen_dist -> EpiData(gen_distribution = gen_dist)

## Calculate the prediction dataframe
prediction_df = mapreduce(vcat, files) do filename
    output = load(joinpath(datadir("epiaware_observables"), filename))
    make_prediction_dataframe_from_output(filename, output, epi_datas, pipelines)
end

## Save the prediction dataframe
CSV.write(plotsdir("analysis_df.csv"), prediction_df)
