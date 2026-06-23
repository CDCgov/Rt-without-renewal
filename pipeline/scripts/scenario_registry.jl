# Shared helper for the Azure Batch task entry points (enumerate_tasks.jl,
# run_truthdata_task.jl, run_inference_task.jl).
#
# Maps a scenario name (== `pipeline.prefix`) to its pipeline constructor so a
# Batch task identified by a scenario string can reconstruct the exact pipeline
# struct. `using EpiAwarePipeline` must already be in scope before including this.

const SCENARIO_PIPELINES = Dict(
    "smooth_outbreak" => SmoothOutbreakPipeline,
    "measures_outbreak" => MeasuresOutbreakPipeline,
    "smooth_endemic" => SmoothEndemicPipeline,
    "rough_endemic" => RoughEndemicPipeline
)

"""
Build the pipeline struct for `scenario`. Extra keyword arguments (e.g. `ndraws`)
are forwarded to the pipeline constructor.
"""
function pipeline_from_scenario(scenario::AbstractString; kwargs...)
    haskey(SCENARIO_PIPELINES, scenario) || error(
        "Unknown scenario \"$scenario\". Known scenarios: " *
        join(sort(collect(keys(SCENARIO_PIPELINES))), ", ") * ".")
    return SCENARIO_PIPELINES[scenario](; kwargs...)
end
