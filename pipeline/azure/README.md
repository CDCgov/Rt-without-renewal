# Running the pipeline on Azure Batch (via cfa-dagster)

The analysis is a fan-out of independent MCMC tasks. Instead of the local
`Distributed`/`pmap` runner (`pipeline/scripts/run_analysis_pipeline.jl`, still
available), this directory drives the same work as discrete Azure Batch tasks
orchestrated by [CDCgov/cfa-dagster](https://github.com/CDCgov/cfa-dagster).

## The DAG

```
enumerate ──> [truthdata tasks] ──(barrier)──> [inference tasks] ──> reduce
              4 scenarios x 3 GIs              ~120 cfg x 3 GIs x N    dataframes + figures
```

- **enumerate** — `pipeline/scripts/enumerate_tasks.jl` prints every task as JSON
  (positional indices). cfa-dagster reads this to build the Batch task graph.
- **truthdata** — `run_truthdata_task.jl <scenario> <gi_index>` writes one truth
  `.jld2`. Cheap; runs first.
- **barrier** — all truthdata must exist before inference (truth simulation is
  unseeded, so inference must *load* not regenerate it — see
  `../PLAN_OPEN_ITEMS.md` item 2).
- **inference** — `run_inference_task.jl <scenario> <gi_index> <config_index>`
  runs one MCMC + forecast + scoring and writes one observables `.jld2`.
- **reduce** — `create_postprocessing_dataframes.jl` + `create_figure{1,2}.jl`
  glob the outputs into CSVs and figures.

Task IDs are positional indices into the deterministic config vectors and are
**only valid for a fixed `Manifest.toml` + source** — both pinned in the image.

## Shared storage

Every task reads/writes one Blob-backed directory **bind-mounted at
`/app/pipeline/data`** (DrWatson's `datadir()` resolves there, and the reduce
readers use the same path). DrWatson `produce_or_load` makes the whole DAG
idempotent: a retried task whose `.jld2` exists short-circuits to a load.

## Build & push the image

From the **repo root** (so `EpiAware/` and `pipeline/` are both in context — the
Manifest's `../EpiAware` dev path needs the sibling layout):

```bash
docker build -f pipeline/azure/Dockerfile -t <registry>/rt-pipeline:<tag> .
docker push <registry>/rt-pipeline:<tag>
```

The build instantiates the pinned `pipeline/Manifest.toml` (Julia 1.10 LTS) and
precompiles, so Batch tasks start fast.

## Run one task locally (sanity check)

```bash
docker run --rm -v $PWD/_run1:/app/pipeline/data <image> \
    pipeline/scripts/run_truthdata_task.jl smooth_outbreak 1 2000
docker run --rm -v $PWD/_run1:/app/pipeline/data <image> \
    pipeline/scripts/run_inference_task.jl smooth_outbreak 1 1 2000
```

## Orchestrate with cfa-dagster

`dagster_defs.py` defines the `rt_pipeline` job (enumerate → truthdata fan-out →
barrier → inference fan-out → reduce). The integration points marked
`# cfa-dagster:` are where you swap the local subprocess dispatch for the Azure
Batch executor and select the image, pool, and Blob IO manager in the
cfa-dagster `Definitions`. Place `dagster_defs.py` per cfa-dagster's image
convention.

> Status: the Julia task units, container, and DAG are validated locally
> (single truthdata + inference task produce real chains/forecasts/scores on
> Julia 1.10). The cfa-dagster executor wiring + Azure pool/registry config are
> environment-specific and marked as TODOs in `dagster_defs.py`.
