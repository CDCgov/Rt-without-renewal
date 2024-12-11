using EpiAwarePipeline, EpiAware, AlgebraOfGraphics, JLD2, DrWatson, DataFramesMeta,
      Statistics, Distributions, DrWatson, CSV

## Define scenarios
scenarios = ["measures_outbreak", "smooth_outbreak", "smooth_endemic", "rough_endemic"]

## Define true GI means
true_gi_means = [2.0, 10.0, 20.0]

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
                return DataFrame()
            end
        end
    end
end

## Save the prediction and scoring dataframes
CSV.write(plotsdir("plotting_data/predictions.csv"), dfs)
