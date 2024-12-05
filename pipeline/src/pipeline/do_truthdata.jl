"""
Generate truth data for the EpiAwarePipeline.

# Arguments
- `pipeline::EpiAwarePipeline`: The EpiAwarePipeline object.

# Returns
An array of truth data generated from the given pipeline.

"""
function do_truthdata(pipeline::AbstractEpiAwarePipeline)
    truth_data_configs = make_truth_data_configs(pipeline)
    truthdata_from_configs = map(truth_data_configs) do truth_data_config
        return generate_truthdata(truth_data_config, pipeline; plot = false)
    end
    return truthdata_from_configs
end

"""
Generate truth data for the given pipeline.

# Arguments
- `pipeline::AbstractRtwithoutRenewalPipeline`: The pipeline object for which to generate truth data.

# Returns
- If `pipeline.priorpredictive` is `true`, returns a list containing a dictionary with missing data and initial values.
- Otherwise, returns a list of spawned tasks that generate truth data based on configurations.

# Details
- When `pipeline.priorpredictive` is `true`, the function returns a dictionary with keys `"y_t"`, `"I_t"`, `"truth_I0"`, and `"truth_gi_mean"`, where `"y_t"` is set to `missing`, `"I_t"` is a vector of 100 elements all set to `1.0`, and both `"truth_I0"` and `"truth_gi_mean"` are set to `1.0`.
- When `pipeline.priorpredictive` is `false`, the function generates truth data configurations using `make_truth_data_configs(pipeline)` and spawns tasks to generate truth data for each configuration.
"""
function do_truthdata(pipeline::AbstractRtwithoutRenewalPipeline)
    if pipeline.priorpredictive
        missingdata = Dict("y_t" => missing, "I_t" => fill(1.0, 100), "truth_I0" => 1.0,
            "truth_gi_mean" => 1.0)
        return [missingdata]
    else
        truth_data_configs = make_truth_data_configs(pipeline)
        truthdata_from_configs = map(truth_data_configs) do truth_data_config
            return generate_truthdata(truth_data_config, pipeline; plot = false)
        end
        return truthdata_from_configs
    end
end
