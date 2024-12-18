using EpiAwarePipeline, EpiAware, JLD2, DrWatson, DataFramesMeta, CSV, MCMCChains

## Define scenarios
scenarios = ["measures_outbreak", "smooth_outbreak", "smooth_endemic", "rough_endemic"]

## Define true GI means
true_gi_means = [2.0, 10.0, 20.0]

if !isfile(plotsdir("plotting_data/predictions.csv"))
    @info "Prediction dataframe does not exist, generating now"
    include("create_prediction_dataframe.jl")
end

if !isfile(plotsdir("plotting_data/truthdata.csv"))
    @info "Truth dataframe does not exist, generating now"
    include("create_truth_dataframe.jl")
end

if !isfile("manuscript/inference_pass_fail_rnd2.csv")
    @info "Diagnostic dataframe does not exist, generating now"
    include("create_mcmc_diagonostic_script.jl")
end
