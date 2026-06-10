# Single truthdata Batch task: generate (and persist) ONE truthdata realisation.
#
# Reconstructs the truthdata config deterministically from its positional index
# and calls generate_truthdata, which writes a `.jld2` to the truth-data dir via
# DrWatson produce_or_load. Idempotent: a re-run loads the existing file.
#
# Data directory: DrWatson `datadir()` resolves to the pipeline project's `data/`.
# For Azure Batch, bind-mount the shared per-run Blob storage at
# <pipeline>/data so every task reads/writes the same state (see pipeline/azure/).
#
# Usage:
#   julia --project=pipeline pipeline/scripts/run_truthdata_task.jl <scenario> <gi_index> [ndraws]

using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))
using EpiAwarePipeline
include(joinpath(@__DIR__, "scenario_registry.jl"))

length(ARGS) >= 2 || error(
    "usage: run_truthdata_task.jl <scenario> <gi_index> [ndraws]")
scenario = ARGS[1]
gi_index = parse(Int, ARGS[2])
ndraws = length(ARGS) >= 3 ? parse(Int, ARGS[3]) : 2000

pipeline = pipeline_from_scenario(scenario; ndraws = ndraws)
truth_configs = make_truth_data_configs(pipeline)
1 <= gi_index <= length(truth_configs) || error(
    "gi_index $gi_index out of range 1:$(length(truth_configs)) for scenario $scenario")

@info "Generating truthdata" scenario gi_index config=truth_configs[gi_index]
generate_truthdata(truth_configs[gi_index], pipeline; plot = false)
@info "Truthdata task complete" scenario gi_index
