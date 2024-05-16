"""
Generate truth data from a configuration file. It does this by converting the
configuration dictionary into a `TruthSimulationConfig` object and then calling
the `simulate` function to generate the truth data.

# Arguments
- `truth_data_config`: A dictionary containing the configuration parameters for
    generating truth data.
- `pipeline::AbstractEpiAwarePipeline`: The pipeline object which sets pipeline
    behavior. This is the default method.
- `plot`: A boolean indicating whether to plot the generated truth data. Default
    is `true`.
- `datadir_str`: A string specifying the directory to save the truth data.
    Default is `"truth_data"`.
- `prefix`: A string specifying the prefix for the truth data file name.
    Default is `"truth_data"`.

# Returns
- `truthdata`: The generated truth data.
- `truthfile`: The file path where the truth data is saved.
"""
function generate_truthdata(
        truth_data_config, pipeline::AbstractEpiAwarePipeline; plot = true,
        datadir_str = "truth_data", prefix = "truth_data")
    true_Rt = default_Rt()
    config = TruthSimulationConfig(
        truth_process = true_Rt, gi_mean = truth_data_config["gi_mean"],
        gi_std = truth_data_config["gi_std"])
    truthdata, truthfile = produce_or_load(
        simulate, config, datadir(datadir_str); prefix = prefix)
    if plot
        plot_truth_data(truthdata, config)
    end
    return truthdata
end
