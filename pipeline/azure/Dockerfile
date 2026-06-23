# Container image for running the Rt-without-renewal pipeline as Azure Batch tasks.
#
# Build from the REPO ROOT so both EpiAware/ and pipeline/ are in the context and
# the Manifest's relative `../EpiAware` dev path resolves:
#
#   docker build -f pipeline/azure/Dockerfile -t <registry>/rt-pipeline:<tag> .
#
# Each Batch task runs one of the task scripts, e.g.:
#   docker run --rm -v /mnt/blob/run1:/app/pipeline/data <image> \
#       pipeline/scripts/run_inference_task.jl smooth_outbreak 1 1 2000
#
# All tasks share output by bind-mounting one Blob-backed directory at
# /app/pipeline/data (DrWatson's datadir() resolves to <project>/data, and the
# postprocessing readers read the same path — so a single mount point makes the
# whole truthdata -> inference -> reduce flow share state). The DrWatson
# produce_or_load cache makes re-runs idempotent on that shared mount.
#
# Julia is pinned to 1.10 (LTS) to match the committed pipeline/Manifest.toml.
FROM julia:1.10.11-bookworm

# git: DrWatson's produce_or_load tags outputs with the git commit.
# fontconfig: CairoMakie text rendering (most deps are vendored via JLLs).
RUN apt-get update && apt-get install -y --no-install-recommends \
        git ca-certificates fontconfig \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the two in-repo packages, preserving the sibling layout that the
# Manifest's `../EpiAware` dev path depends on.
COPY EpiAware/ ./EpiAware/
COPY pipeline/ ./pipeline/

# Instantiate the pinned environment at build time (dev EpiAware + precompile).
# Bakes the depot into the image so Batch tasks start fast.
ENV JULIA_DEPOT_PATH=/usr/local/julia/depot
RUN julia pipeline/scripts/setup.jl

# Shared output directory. The orchestrator bind-mounts the per-run Blob storage
# here so every task (truthdata, inference, reduce) reads/writes the same state.
VOLUME ["/app/pipeline/data"]

# Run a task script: ENTRYPOINT fixes the project, CMD args pick the script.
#   <image> pipeline/scripts/run_inference_task.jl <scenario> <gi> <cfg> <ndraws>
ENTRYPOINT ["julia", "--project=/app/pipeline"]
CMD ["pipeline/scripts/enumerate_tasks.jl"]
