# Emit the full task manifest (truthdata + inference tasks) as JSON to stdout.
#
# Consumed by the external orchestrator (CDCgov/cfa-dagster) to build the Azure
# Batch DAG: each emitted object maps to one Batch task command. Task identity is
# a tuple of *positional indices* into the deterministic config vectors produced
# by `make_truth_data_configs` / `make_inference_configs`, so a task ID
# reconstructs the same config when passed to the runner scripts.
#
# IMPORTANT: indices are only valid for a fixed Manifest.toml + source. The Docker
# image pins both. Never mix a manifest enumerated by one image with execution by
# another. (See pipeline/PLAN_OPEN_ITEMS.md item 4.)
#
# Usage:
#   julia --project=pipeline pipeline/scripts/enumerate_tasks.jl [scenario]
# With no argument, enumerates all four scenarios.

using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))
using EpiAwarePipeline
include(joinpath(@__DIR__, "scenario_registry.jl"))

# --- minimal JSON serialisation (avoids adding a JSON dependency) ------------
_jstr(s) = '"' * replace(string(s), '\\' => "\\\\", '"' => "\\\"") * '"'
_jval(x::AbstractString) = _jstr(x)
_jval(x::Symbol) = _jstr(x)
_jval(x::Bool) = x ? "true" : "false"
_jval(x::Integer) = string(x)
_jval(x::Real) = string(x)
_jval(x) = _jstr(x)
_jobj(pairs) = "{" * join([_jstr(k) * ":" * _jval(v) for (k, v) in pairs], ",") * "}"

function tasks_for_scenario(scenario::AbstractString)
    pipeline = pipeline_from_scenario(scenario)
    objs = String[]

    truth_configs = make_truth_data_configs(pipeline)
    for (gi_index, cfg) in enumerate(truth_configs)
        push!(objs,
            _jobj([
                "type" => "truthdata", "scenario" => scenario, "gi_index" => gi_index,
                "gi_mean" => cfg["gi_mean"], "gi_std" => cfg["gi_std"]
            ]))
    end

    # Every inference config is fit against every truthdata realisation (the
    # config's gi_mean is the *assumed* GI, which may be misspecified relative to
    # the truthdata's *true* GI). So inference tasks are the full Cartesian
    # product of (gi_index, config_index), matching do_pipeline's nested loop.
    # Each inference task depends on the truthdata task with the same gi_index.
    inf_configs = make_inference_configs(pipeline)
    for (gi_index, tcfg) in enumerate(truth_configs)
        for (config_index, cfg) in enumerate(inf_configs)
            push!(objs,
                _jobj([
                    "type" => "inference", "scenario" => scenario,
                    "gi_index" => gi_index, "config_index" => config_index,
                    "igp" => string(cfg["igp"]),
                    "latent_model" => cfg["latent_namemodels"].first,
                    "used_gi_mean" => cfg["gi_mean"], "truth_gi_mean" => tcfg["gi_mean"],
                    "T" => cfg["T"]
                ]))
        end
    end
    return objs
end

scenarios = isempty(ARGS) ? sort(collect(keys(SCENARIO_PIPELINES))) : [ARGS[1]]
all_objs = vcat((tasks_for_scenario(s) for s in scenarios)...)
println("[" * join(all_objs, ",") * "]")
