# Single inference Batch task: fit ONE inference config against ONE truthdata.
#
# Reconstructs both the truthdata config (by gi_index) and the inference config
# (by config_index) deterministically, loads the persisted truthdata, and runs
# generate_inference_results for just that config — writing one `.jld2` to the
# inference output dir via DrWatson produce_or_load. Idempotent: a re-run of a
# completed config short-circuits to a load.
#
# DEPENDENCY: the matching truthdata task (same scenario + gi_index) MUST have run
# first. truthdata simulation is currently unseeded (see pipeline/PLAN_OPEN_ITEMS.md
# item 2), so the truthdata file must already exist — otherwise this task would
# regenerate a *different* realisation than other inference tasks used. We error
# (rather than silently resampling) if no truthdata file exists. The orchestrator
# enforces the truthdata -> inference ordering as a DAG edge.
#
# Data directory: see run_truthdata_task.jl header — bind-mount shared Blob
# storage at <pipeline>/data so truthdata written by the truthdata task is visible.
#
# Usage:
#   julia --project=pipeline pipeline/scripts/run_inference_task.jl <scenario> <gi_index> <config_index> [ndraws]

using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))
using EpiAwarePipeline
using DrWatson: produce_or_load
include(joinpath(@__DIR__, "scenario_registry.jl"))

length(ARGS) >= 3 || error(
    "usage: run_inference_task.jl <scenario> <gi_index> <config_index> [ndraws]")
scenario = ARGS[1]
gi_index = parse(Int, ARGS[2])
config_index = parse(Int, ARGS[3])
ndraws = length(ARGS) >= 4 ? parse(Int, ARGS[4]) : 2000

pipeline = pipeline_from_scenario(scenario; ndraws = ndraws)

truth_configs = make_truth_data_configs(pipeline)
1 <= gi_index <= length(truth_configs) || error(
    "gi_index $gi_index out of range 1:$(length(truth_configs)) for scenario $scenario")

inf_configs = make_inference_configs(pipeline)
1 <= config_index <= length(inf_configs) || error(
    "config_index $config_index out of range 1:$(length(inf_configs)) for scenario $scenario")

# Load the truthdata realisation. generate_truthdata is load-or-produce; because
# the truthdata task already wrote the file this is a load. Guard against an
# accidental resample (would be inconsistent under the unseeded simulation).
truthdir = EpiAwarePipeline._get_truthdatadir_str(pipeline)
had_truthfiles = isdir(truthdir) && !isempty(readdir(truthdir))
had_truthfiles ||
    error("No existing truthdata files found in $truthdir; the matching truthdata task " *
          "(same scenario + gi_index) must run before this inference task. truthdata " *
          "simulation is unseeded, so resampling here would produce a different " *
          "realisation than other inference tasks use (PLAN_OPEN_ITEMS item 2).")
truthdata = generate_truthdata(truth_configs[gi_index], pipeline; plot = false)

@info "Running inference" scenario gi_index config_index igp=string(inf_configs[config_index]["igp"]) T=inf_configs[config_index]["T"]
generate_inference_results(truthdata, inf_configs[config_index], pipeline)
@info "Inference task complete" scenario gi_index config_index
