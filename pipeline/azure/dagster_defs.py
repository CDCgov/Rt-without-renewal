"""Dagster definitions for the Rt-without-renewal pipeline on Azure Batch.

This orchestrates the three stages of the analysis as a fan-out DAG:

    enumerate -> [truthdata tasks] --(barrier)--> [inference tasks] -> reduce

Each Julia task is a single-process invocation of a script in pipeline/scripts/,
run inside the container image built from pipeline/azure/Dockerfile. On Azure
Batch (via CDCgov/cfa-dagster's custom executor) each op below is dispatched as a
Batch task running that image; locally they run as subprocesses.

Task identity is a tuple of positional indices into the deterministic config
vectors (see pipeline/scripts/enumerate_tasks.jl) — valid only for a fixed
Manifest + source, both pinned in the image.

Shared state: every task reads/writes one Blob-backed directory bind-mounted at
/app/pipeline/data (DrWatson's datadir()). The produce_or_load cache makes the
whole DAG idempotent — a retried task that already wrote its .jld2 short-circuits.

INTEGRATION POINTS for cfa-dagster (marked `# cfa-dagster:` below):
  - swap the local `_run_julia` subprocess for the Azure Batch executor / a
    containerized op so each task runs as a Batch task with the image + blob mount.
  - configure the executor, image reference, pool, and Blob IO in the cfa-dagster
    Definitions/executor config rather than here.
"""

from __future__ import annotations

import json
import subprocess

from dagster import (
    Config,
    DynamicOut,
    DynamicOutput,
    In,
    Nothing,
    OpExecutionContext,
    Out,
    job,
    op,
)

# Julia entrypoint inside the container image (matches the Dockerfile ENTRYPOINT).
JULIA = ["julia", "--project=/app/pipeline"]
SCRIPTS = "pipeline/scripts"

DEFAULT_SCENARIOS = [
    "smooth_outbreak",
    "measures_outbreak",
    "smooth_endemic",
    "rough_endemic",
]


class RunConfig(Config):
    ndraws: int = 2000
    scenarios: list[str] = DEFAULT_SCENARIOS


def _run_julia(context: OpExecutionContext, script: str, *args: object) -> None:
    """Run one Julia task script.

    # cfa-dagster: replace this with the Batch-task dispatch (run the image with
    # `[*JULIA, script, *args]` as the command and the per-run Blob mount). The
    # rest of the DAG (fan-out, barrier, idempotency) is unchanged.
    """
    cmd = [*JULIA, script, *[str(a) for a in args]]
    context.log.info("RUN %s", " ".join(cmd))
    subprocess.run(cmd, check=True)


@op(out=Out(list))
def enumerate_tasks(context: OpExecutionContext, config: RunConfig) -> list[dict]:
    """Produce the full task manifest by calling enumerate_tasks.jl per scenario."""
    tasks: list[dict] = []
    for scenario in config.scenarios:
        out = subprocess.run(
            [*JULIA, f"{SCRIPTS}/enumerate_tasks.jl", scenario],
            check=True,
            capture_output=True,
            text=True,
        )
        tasks.extend(json.loads(out.stdout))
    n_truth = sum(t["type"] == "truthdata" for t in tasks)
    n_inf = sum(t["type"] == "inference" for t in tasks)
    context.log.info("enumerated %d truthdata + %d inference tasks", n_truth, n_inf)
    return tasks


@op(out=DynamicOut())
def fan_out_truthdata(tasks: list[dict]):
    for t in tasks:
        if t["type"] == "truthdata":
            key = f'{t["scenario"]}__gi{t["gi_index"]}'
            yield DynamicOutput(t, mapping_key=key)


@op(out=Out(Nothing))
def run_truthdata(context: OpExecutionContext, config: RunConfig, task: dict) -> None:
    _run_julia(
        context,
        f"{SCRIPTS}/run_truthdata_task.jl",
        task["scenario"],
        task["gi_index"],
        config.ndraws,
    )


@op(out=DynamicOut(), ins={"start": In(Nothing)})
def fan_out_inference(tasks: list[dict]):
    for t in tasks:
        if t["type"] == "inference":
            key = f'{t["scenario"]}__gi{t["gi_index"]}__cfg{t["config_index"]}'
            yield DynamicOutput(t, mapping_key=key)


@op(out=Out(Nothing))
def run_inference(context: OpExecutionContext, config: RunConfig, task: dict) -> None:
    _run_julia(
        context,
        f"{SCRIPTS}/run_inference_task.jl",
        task["scenario"],
        task["gi_index"],
        task["config_index"],
        config.ndraws,
    )


@op(ins={"start": In(Nothing)}, out=Out(Nothing))
def reduce_postprocessing(context: OpExecutionContext) -> None:
    """Build the prediction/truth/diagnostic dataframes and figures once all
    inference tasks have completed."""
    _run_julia(context, f"{SCRIPTS}/create_postprocessing_dataframes.jl")
    _run_julia(context, f"{SCRIPTS}/create_figure1.jl")
    _run_julia(context, f"{SCRIPTS}/create_figure2.jl")


@job
def rt_pipeline():
    tasks = enumerate_tasks()

    # Stage 1: truthdata fan-out. `.collect()` is the BARRIER — every truthdata
    # task must finish before any inference task starts (truthdata simulation is
    # unseeded, so it must exist before inference loads it; PLAN_OPEN_ITEMS #2).
    truth_done = fan_out_truthdata(tasks).map(run_truthdata).collect()

    # Stage 2: inference fan-out, gated on truthdata completion via the `start`
    # Nothing-input barrier, then one inference op per (scenario, gi, config).
    inf_done = fan_out_inference(tasks, start=truth_done).map(run_inference).collect()

    # Stage 3: reduce, gated on all inference completing.
    reduce_postprocessing(start=inf_done)


# cfa-dagster: register `rt_pipeline` in the project's Definitions and select the
# Azure Batch executor + Blob IO manager there. A minimal local Definitions:
#
#   from dagster import Definitions
#   defs = Definitions(jobs=[rt_pipeline])
#
# Note: the inference fan-out is ~120 configs x 3 GIs x N scenarios (e.g. 1440
# tasks for all 4). Configure Batch pool size / Dagster op concurrency to taste;
# idempotent produce_or_load means partial runs resume cleanly on retry.
