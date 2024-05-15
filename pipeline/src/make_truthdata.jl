"""
Generate truth data for the EpiAwarePipeline.

# Arguments
- `pipeline::EpiAwarePipeline`: The EpiAwarePipeline object.

# Returns
An array of truth data generated from the given pipeline.

"""
function make_truthdata(pipeline::EpiAwarePipeline)
    truth_data_configs = default_truthdata_configs()
    truthdata_from_configs = map(truth_data_configs) do truth_data_config
        return Dagger.@spawn cache=true generate_truthdata_from_config(
            truth_data_config; plot = false)
    end
    return truthdata_from_configs
end
