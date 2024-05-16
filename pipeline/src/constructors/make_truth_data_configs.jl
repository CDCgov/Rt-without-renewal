"""
Create a dictionary of truth data configurations for `pipeline <: AbstractEpiAwarePipeline`.
    This is the default method.

# Returns
A vector of dictionaries containing the mean and standard deviation values for
    the generation interval.

"""
function make_truth_data_configs(pipeline::AbstractEpiAwarePipeline)
    default_truthdata_configs()
end
