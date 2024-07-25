"""
Internal method for setting the prefix for the truth data file name.
"""
_simulate_prefix(pipeline::AbstractEpiAwarePipeline) = "truth_data"
function _simulate_prefix(pipeline::AbstractRtwithoutRenewalPipeline)
    "truth_data_" * pipeline.prefix
end
