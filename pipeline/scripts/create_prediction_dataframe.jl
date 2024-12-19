## Structure to record success/failure
success_configs = Dict[]
failed_configs = Dict[]

## Analysis of the prediction dataframes
dfs = mapreduce(vcat, scenarios) do scenario
    mapreduce(vcat, true_gi_means) do true_gi_mean
        target_str = "truth_gi_mean_" * string(true_gi_mean) * "_"
        files = readdir(datadir("epiaware_observables/" * scenario)) |>
                strs -> filter(s -> occursin("jld2", s), strs) |>
                        strs -> filter(s -> occursin(target_str, s), strs)

        mapreduce(vcat, files) do filename
            output = load(joinpath(datadir("epiaware_observables"), scenario, filename))
            try
                push!(success_configs,
                    merge(output["inference_config"], Dict("runsuccess" => true)))
                make_prediction_dataframe_from_output(output, true_gi_mean, scenario)
            catch e
                @warn "Error in $filename"
                push!(failed_configs,
                    merge(output["inference_config"], Dict("runsuccess" => false)))
                return DataFrame()
            end
        end
    end
end

## Gather the pass/failed data
pass_fail_df = mapreduce(vcat, [success_configs; failed_configs]) do D
    igp = D["igp"] |> str -> split(str, ".")[end]
    latent_model = D["latent_model"]
    gi_mean = D["gi_mean"]
    T1, T2 = split(D["tspan"], "_")
    df = DataFrame(
        infection_gen_proc = igp,
        latent_model = latent_model,
        gi_mean = gi_mean,
        T1 = T1,
        T2 = T2,
        T_diff = parse(Int, T2) - parse(Int, T1),
        runsuccess = D["runsuccess"]
    )
end

## Save the prediction and failed dataframes
CSV.write(plotsdir("plotting_data/predictions.csv"), dfs)
CSV.write("manuscript/inference_pass_fail_rnd2.csv", pass_fail_df)
