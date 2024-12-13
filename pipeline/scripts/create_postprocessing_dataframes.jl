using EpiAwarePipeline, EpiAware, JLD2, DrWatson, DataFramesMeta, CSV

## Define scenarios
scenarios = ["measures_outbreak", "smooth_outbreak", "smooth_endemic", "rough_endemic"]

if !isfile(plotsdir("plotting_data/predictions.csv"))
    @info "Prediction dataframe does not exist, generating now"
    include("create_prediction_dataframe.jl")
end

if !isfile(plotsdir("plotting_data/truthdata.csv"))
    @info "Truth dataframe does not exist, generating now"
    include("create_truth_dataframe.jl")
end
