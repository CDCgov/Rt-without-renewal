"""
Generate truth data from a configuration file. It does this by converting the
configuration dictionary into a `TruthSimulationConfig` object and then calling
the `simulate` function to generate the truth data. This is the default method.

# Arguments
- `truth_data_config`: A dictionary containing the configuration parameters for
    generating truth data.
- `pipeline::AbstractEpiAwarePipeline`: The pipeline object which sets pipeline
    behavior.
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
    true_Rt = make_Rt(pipeline)
    config = TruthSimulationConfig(
        truth_process = true_Rt, gi_mean = truth_data_config["gi_mean"],
        gi_std = truth_data_config["gi_std"])
    truthdata, truthfile = produce_or_load(
        simulate, config, datadir(datadir_str); prefix = prefix)
    if plot
        plot_truth_data(truthdata, config, pipeline)
    end
    return truthdata
end

"""
Generate truth data from a configuration file. It does this by converting the
configuration dictionary into a `TruthSimulationConfig` object and then calling
the `simulate` function to generate the truth data. This is the example method
which saves to a temporary directory, which is deleted after the function call.

# Arguments
- `truth_data_config`: A dictionary containing the configuration parameters for
    generating truth data.
- `pipeline::AbstractEpiAwarePipeline`: The pipeline object which sets pipeline
    behavior.
- `plot`: A boolean indicating whether to plot the generated truth data. Default
    is `true`.
- `prefix`: A string specifying the prefix for the truth data file name.
    Default is `"truth_data"`.

# Returns
- `truthdata`: The generated truth data.
- `truthfile`: The file path where the truth data is saved.
"""
function generate_truthdata(
        truth_data_config, pipeline::EpiAwareExamplePipeline; plot = true, prefix = "truth_data")
    true_Rt = make_Rt(pipeline)
    config = TruthSimulationConfig(
        truth_process = true_Rt, gi_mean = truth_data_config["gi_mean"],
        gi_std = truth_data_config["gi_std"])

    datadir_str, io = mktemp(; cleanup=true)
    truthdata, truthfile = produce_or_load(
        simulate, config, datadir_str; prefix = prefix)
    if plot
        plot_truth_data(truthdata, config, pipeline)
    end
    return truthdata
end
