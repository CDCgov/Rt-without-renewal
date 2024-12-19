using EpiAwarePipeline, EpiAware, JLD2, DrWatson, DataFramesMeta, CSV, MCMCChains

pipelinetypes = [
    MeasuresOutbreakPipeline,
    SmoothOutbreakPipeline,
    SmoothEndemicPipeline,
    RoughEndemicPipeline
]
## Define scenarios

scenarios = pipelinetypes .|> pipetype -> pipetype().prefix

## Define true GI means
# Errors if not the same for all pipeline types
true_gi_means = map(pipelinetypes) do pipetype
    make_gi_params(pipetype())["gi_means"]
end |>
                ensemble_gi_means -> all([gi_means == ensemble_gi_means[1]
                                          for gi_means in ensemble_gi_means]) ?
                                     ensemble_gi_means[1] :
                                     error("GI means are not the same")

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
