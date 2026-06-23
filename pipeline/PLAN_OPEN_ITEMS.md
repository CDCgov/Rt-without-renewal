# Pipeline completion — open items

Decisions to steer before / during implementation of the pipeline-completion work
(plan: get `/pipeline` running on Julia 1.10 locally, then fan out on Azure Batch
via cfa-dagster). Each item blocks the linked implementation step until resolved.
Edit the **Decision** lines; check the box when settled.

---

## 1. `DistributionsF32.jl` access and API  — blocks: SafeNegativeBinomial fix
- [ ] **Status:** `SamuelBrand1/DistributionsF32.jl` is not publicly resolvable from
  this machine (GitHub returns 404 — private or unregistered). Need the repo URL /
  registry status and the exact public API (constructor + `rand` for the negative
  binomial / Poisson).
- **Options:**
  - (a) Add `DistributionsF32` as an EpiAware dep and route
    `rand(::SafeNegativeBinomial)` (and `SafePoisson` if needed) through it.
  - (b) Fallback: fix the overflow in-place in
    `EpiAware/src/EpiAwareUtils/SafeNegativeBinomial.jl` /
    `SafePoisson.jl` — clamp the sampled rate to a safe `Int64` ceiling so the
    `BigInt` path can't produce values that later fail `Int64` conversion.
- **Decision:** _TBD — provide DistributionsF32 URL/access, or choose fallback (b)._
- **UPDATE (validation):** the negbin overflow is **not** what blocked inference.
  Truth-data simulation and a full inference run both proceed without an
  `InexactError` for the smooth_outbreak / short-GI config tested. The real
  blocker was the Pathfinder ↔ DynamicPPL incompatibility (item 7). So this fix is
  now **lower priority / hardening only** — revisit if specific wide-prior
  configs surface the overflow during the full sweep.

## 2. Deterministic seeding of truth-data simulation  — blocks: Batch correctness
- [ ] **Status:** `simulate` (`pipeline/src/simulate/TruthSimulationConfig.jl`) uses
  the global RNG with no seed. The truthdata→inference task barrier (truthdata
  generated once, before any inference reads it) is mandatory regardless. Question
  is whether to also seed for reproducibility.
- **Options:**
  - (a) Barrier only (truthdata generated once per `(scenario, gi_index)`, cached,
    inference tasks only ever *load* it).
  - (b) Barrier + deterministic seed keyed on `(scenario, gi_index)` so a
    regenerated truthdata file is bit-reproducible (defense-in-depth).
- **Decision:** _TBD._

## 3. Transitive dependency resolution on Julia 1.10  — RESOLVED
- [x] **Status:** The pipeline env resolves and precompiles cleanly on Julia
  1.10.11 (611 deps) with no transitive compromises — no bound on CairoMakie /
  Pathfinder / Turing / DPPL needed loosening. Resolved versions (now pinned in
  `pipeline/Manifest.toml`): EpiAware 0.2.0, Turing 0.35.5, DynamicPPL 0.32.2,
  Distributions 0.25.126, AbstractMCMC 5.15.1, AdvancedHMC 0.6.4,
  CairoMakie 0.15.11, Pathfinder 0.9.26.
- **Constraint honoured:** Turing/DynamicPPL were not bumped.

## 4. Task-index validity across image builds  — informational
- [ ] **Status:** Batch task IDs are positional indices into
  `make_truth_data_configs` / `make_inference_configs`. They are only valid for a
  fixed `Manifest.toml` + identical source. Never mix a manifest enumerated by one
  image with execution by another.
- **Decision:** _Acknowledge; the Docker image pins both, so OK within one build._

## 5. EpiAware compat relaxation scope  — RESOLVED
- [x] **Done:** `EpiAware/Project.toml` relaxed `julia = "1.10, 1.11"` and the
  three stdlib pins (`Random`, `Statistics`, `SparseArrays`) to `"1.10, 1.11"`.
  (`Tables`/`FillArrays` at `"1.11"` are package versions, not stdlibs — left as
  is.) Non-stdlib package bounds unchanged. `pipeline`/`pipeline/test`
  `EpiAware = "0.1.0"` bumped to `"0.2"` (the actual resolve blocker — local
  EpiAware is 0.2.0).
- **Rationale (user):** Julia **1.10 is the LTS**, so pinning the pipeline to it
  is reasonable. EpiAware compat keeps 1.11 allowed so EpiAware's own CI (which
  tests 1.11 / 1.latest) is unaffected; the *pipeline* is pinned to 1.10 via the
  committed Manifest + the repo's `juliaup override`.

## 6. Pipeline ↔ EpiAware 0.2 API drift  — IN PROGRESS (handed to Claude)
- [x] `AR`/`RandomWalk` `std_prior` kwarg removed in EpiAware 0.2 → innovation std
  now lives in `ϵ_t = HierarchicalNormal(std_prior = σ)`. Fixed in
  `make_epiaware_name_latentmodel_pairs.jl` and `remake_latent_model.jl`
  (semantics preserved). Validated: `enumerate_tasks.jl` builds all 120 configs.
- [ ] Further drift may surface when running inference/forecast/scoring; chasing
  it down as part of end-to-end validation.

## 7. Pathfinder ↔ DynamicPPL 0.32 incompatibility  — THE real blocker (fix applied)
- [x] **Root cause:** the pre-sampler `ManyPathfinder` failed on every run
  ("All pathfinder runs failed after 100 tries"), so inference returned a caught
  error string. The underlying cause (hidden by ManyPathfinder's bare `catch`):
  Pathfinder 0.9.26's `PathfinderTuringExt.draws_to_chains` calls
  `DynamicPPL.values_as_in_model(model, ::Bool, varinfo)`, a signature that exists
  only in DynamicPPL ≥ 0.35. Turing 0.35 pins DynamicPPL 0.32, which has no `Bool`
  form. Pathfinder declares **no** DynamicPPL compat bound, so the resolver silently
  paired an incompatible version.
- **Fix applied:** capped `Pathfinder = "0.9.0 - 0.9.21"` in `EpiAware/Project.toml`
  (compat-only). 0.9.21 is the last release whose Turing extension uses the
  DynamicPPL-0.32-compatible code path and explicitly declares DPPL 0.32 / Turing
  0.35 support. Re-resolving + re-validating an inference run.
- **Decision for you:** OK to keep this Pathfinder cap? (Alternative would be
  dropping the Pathfinder pre-sampler and running NUTS from default init — a
  methodology change. The cap preserves the intended methodology.)

---

## Process
- **No PR** until the user has reviewed the work. Commits on the working branch are
  fine; hold the PR.
