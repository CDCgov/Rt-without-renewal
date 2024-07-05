"""
Internal method for setting the prefix for the truth data file name.
"""
_simulate_prefix(pipeline::AbstractEpiAwarePipeline) = "truth_data"

_simulate_prefix(pipeline::SmoothOutbreakPipeline) = "truth_data_smooth_outbreak"

_simulate_prefix(pipeline::MeasuresOutbreakPipeline) = "truth_data_measures_outbreak"

_simulate_prefix(pipeline::SmoothEndemicPipeline) = "truth_data_smooth_endemic"

_simulate_prefix(pipeline::RoughEndemicPipeline) = "truth_data_rough_endemic"
