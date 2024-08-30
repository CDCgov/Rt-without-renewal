"""
Internal method for setting the prefix for the truth data file name.
"""
_simulate_prefix(pipeline::AbstractEpiAwarePipeline) = "truth_data"
function _simulate_prefix(pipeline::AbstractRtwithoutRenewalPipeline)
    "truth_data_" * pipeline.prefix
end

"""
Internal method for setting the data directory path for the truth data.
"""
_get_truthdatadir_str(pipeline::AbstractEpiAwarePipeline) = "truth_data"
function _get_truthdatadir_str(pipeline::AbstractRtwithoutRenewalPipeline)
    pipeline.testmode ? mktempdir() : "truth_data"
end
