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
        return Dagger.@spawn cache=true generate_truthdata(
            truth_data_config, pipeline; plot = false)
    end
    return truthdata_from_configs
end
