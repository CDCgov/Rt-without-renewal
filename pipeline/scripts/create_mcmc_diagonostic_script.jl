## Analysis of the prediction dataframes for mcmc diagnostics
diagnostic_df = mapreduce(vcat, scenarios) do scenario
    mapreduce(vcat, true_gi_means) do true_gi_mean
        target_str = "truth_gi_mean_" * string(true_gi_mean) * "_"
        files = readdir(datadir("epiaware_observables/" * scenario)) |>
                strs -> filter(s -> occursin("jld2", s), strs) |>
                        strs -> filter(s -> occursin(target_str, s), strs)

        mapreduce(vcat, files) do filename
            output = load(joinpath(datadir("epiaware_observables"), scenario, filename))
            try
                make_mcmc_diagnostic_dataframe(output, true_gi_mean, scenario)
            catch e
            end
        end
    end
end

## Save the mcmc diagnostics
CSV.write("manuscript/inference_diagnostics_rnd2.csv", diagnostic_df)
