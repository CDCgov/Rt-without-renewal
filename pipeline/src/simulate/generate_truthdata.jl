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
        truth_data_config, pipeline::AbstractEpiAwarePipeline; plot = true)
    default_params = make_default_params(pipeline)
    config = TruthSimulationConfig(
        truth_process = default_params["Rt"], gi_mean = truth_data_config["gi_mean"],
        gi_std = truth_data_config["gi_std"], logit_daily_ascertainment = default_params["logit_daily_ascertainment"],
        cluster_factor = default_params["cluster_factor"], I0 = default_params["I0"])

    prefix = _simulate_prefix(pipeline)
    _datadir_str = _get_truthdatadir_str(pipeline)

    truthdata, truthfile = produce_or_load(
        simulate, config, _datadir_str; prefix = prefix)
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
        truth_data_config, pipeline::EpiAwareExamplePipeline; plot = true,
        prefix = "truth_data")
    default_params = make_default_params(pipeline)
    config = TruthSimulationConfig(
        truth_process = default_params["Rt"], gi_mean = truth_data_config["gi_mean"],
        gi_std = truth_data_config["gi_std"], logit_daily_ascertainment = default_params["logit_daily_ascertainment"],
        cluster_factor = default_params["cluster_factor"], I0 = default_params["I0"])
    datadir_str = mktempdir()

    truthdata, truthfile = produce_or_load(
        simulate, config, datadir(datadir_str); prefix = prefix)
    if plot
        plot_truth_data(truthdata, config, pipeline)
    end
    return truthdata
end
