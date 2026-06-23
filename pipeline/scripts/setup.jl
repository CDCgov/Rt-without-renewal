# Set up the pipeline environment.
#
# EpiAware is a local, unregistered package living in-repo at ../../EpiAware. On
# Julia 1.11+ this would be wired with a `[sources]` entry in pipeline/Project.toml,
# but `[sources]` is NOT supported on Julia 1.10 — so we `Pkg.develop` the local
# path instead. This records EpiAware as a dev-dependency in pipeline/Manifest.toml.
#
# Run once after checkout (or whenever EpiAware's path/version changes):
#   julia --project=pipeline pipeline/scripts/setup.jl
#
# Idempotent: re-running just re-resolves against the committed Manifest.

using Pkg

pipeline_dir = abspath(joinpath(@__DIR__, ".."))
Pkg.activate(pipeline_dir)

# Point the env at the in-repo EpiAware (substitute for [sources] on Julia 1.10).
# Use a path *relative to the pipeline project* so the committed Manifest is
# portable across machines and into the Docker image (which preserves the repo
# layout). Running from the pipeline dir makes Pkg record `path = "../EpiAware"`.
cd(pipeline_dir) do
    Pkg.develop(path = "../EpiAware")
end

Pkg.instantiate()
Pkg.precompile()

@info "Pipeline environment resolved. Smoke-loading EpiAwarePipeline…"
using EpiAwarePipeline
@info "EpiAwarePipeline loaded OK" julia = string(VERSION)
