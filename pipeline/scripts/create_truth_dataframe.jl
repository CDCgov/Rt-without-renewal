truth_df = mapreduce(vcat, scenarios) do scenario
    truth_data_files = readdir(datadir("truth_data")) |>
                       strs -> filter(s -> occursin("jld2", s), strs) |>
                               strs -> filter(s -> occursin(scenario, s), strs)
    mapreduce(vcat, truth_data_files) do filename
        D = load(joinpath(datadir("truth_data"), filename))
        make_truthdata_dataframe(D, scenario)
    end
end

CSV.write(plotsdir("plotting_data/truthdata.csv"), truth_df)
