using EpiAwarePipeline, EpiAware, AlgebraOfGraphics, JLD2, DrWatson, DataFramesMeta,
      Statistics, Distributions, DrWatson, CSV

## Define scenarios
scenarios = ["measures_outbreak", "smooth_outbreak", "smooth_endemic", "rough_endemic"]

## Define true GI means
true_gi_means = [2.0, 10.0, 20.0]

## Load the prediction dataframes or record fails
failed_configs = Dict[]

dfs = mapreduce(vcat, scenarios) do scenario
    mapreduce(vcat, true_gi_means) do true_gi_mean
        target_str = "truth_gi_mean_" * string(true_gi_mean) * "_"
        files = readdir(datadir("epiaware_observables/" * scenario)) |>
                strs -> filter(s -> occursin("jld2", s), strs) |>
                        strs -> filter(s -> occursin(target_str, s), strs)

        mapreduce(vcat, files) do filename
            output = load(joinpath(datadir("epiaware_observables"), scenario, filename))
            try
                make_prediction_dataframe_from_output(output, true_gi_mean)
            catch e
                @warn "Error in $filename"
                push!(failed_configs, output["inference_config"])
                return DataFrame()
            end
        end
    end
end

## Gather the failed data
failed_df = mapreduce(vcat, failed_configs) do D
    igp = D["igp"] |> str -> split(str, ".")[end]
    latent_model = D["latent_model"]
    gi_mean = D["gi_mean"]
    T1, T2 = split(D["tspan"], "_")
    runsuccess = D["priorpredictive"] .== "Pass"
    df = DataFrame(
        infection_gen_proc = igp,
        latent_model = latent_model,
        gi_mean = gi_mean,
        T1 = T1,
        T2 = T2,
        T_diff = parse(Int, T2) - parse(Int, T1),
        runsuccess = runsuccess
    )
end

##
grped_failed_df = failed_df |>
                  df -> @groupby(df, :infection_gen_proc, :latent_model) |>
                        gd -> @combine(gd, :n_success=sum(:runsuccess),
    :n_fail=sum(1 .- :runsuccess))

## Save the prediction and failed dataframes
CSV.write(plotsdir("plotting_data/predictions.csv"), dfs)
CSV.write(plotsdir("plotting_data/failed_preds.csv"), failed_df)
