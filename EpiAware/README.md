# EpiAware.jl

[![SciML Code Style](https://img.shields.io/static/v1?label=code%20style&message=SciML&color=9558b2&labelColor=389826)](https://github.com/SciML/SciMLStyle)
![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)
[![Test EpiAware](https://github.com/CDCgov/Rt-without-renewal/actions/workflows/test-EpiAware.yaml/badge.svg)](https://github.com/CDCgov/Rt-without-renewal/actions/workflows/test-EpiAware.yaml)
[![codecov](https://codecov.io/gh/CDCgov/Rt-without-renewal/graph/badge.svg?token=IX4GIA8F0H)](https://codecov.io/gh/CDCgov/Rt-without-renewal)

A `Julia` package for flexible and composable modeling and inference of the effective reproduction number (Rt) and other situational awareness signals in the presence of different latent generative processes and observation models.

## Installation instruction

Eventually, `EpiAware` is likely to be added to the Julia registry. Until then, you can install it from the `/EpiAware` sub-directory of this repository by running the following command in the Julia REPL:

```julia
using Pkg; Pkg.add(url="https://github.com/CDCgov/Rt-without-renewal", subdir="EpiAware")
```

## Model Diagram

- Solid lines indicate implemented features/analysis.
- Dashed lines indicate planned features/analysis.

## Current `EpiAware` model diagram
```mermaid
flowchart LR

A["Underlying GI
Bijector"]

EpiModel["AbstractTuringEpiModel
----------------------
Choice of target
for latent process:

DirectInfections
    ExpGrowthRate
    Renewal"]

InitModel["Priors for
initial scale of incidence"]

DataW[Data wrangling and QC]


ObsData["Observational Data
---------------------
Obs. cases y_t"]

LatentProcPriors["Latent process priors"]

LatentProc["AbstractTuringLatentModel
---------------------
RandomWalk"]

ObsModelPriors["Observation model priors
choice of delayed obs. model"]

ObsModel["AbstractObservationModel
---------------------
DelayObservations"]

E["Turing model constructor
---------------------
generate_epiaware"]

G[Posterior draws]
H[Posterior checking]
I[Post-processing]



A --> EpiData
EpiData --> EpiModel
InitModel --> EpiModel
EpiModel -->E
ObsData-->E
DataW-.->ObsData
LatentProcPriors-->LatentProc
LatentProc-->E
ObsModelPriors-->ObsModel
ObsModel-->E


E-->|sample...NUTS...| G
G-.->H
H-.->I
```

## Pluto scripts

We use [`Pluto.jl`](https://plutojl.org/) scripts as part of our documentation and testing. The scripts are located in `docs/src/examples` and can be run using the `Pluto.jl` package. We recommend using the version of `Pluto` that is pinned in the `Project.toml` file defining the documentation environment. An entry point to running or developing this documentation is the `docs/pluto-scripts.sh` bash shell script. Run this from the root directory of this repository.

## Opinionated guide to using Julia for project development
Some user and potential contributors may not be familiar with using Julia for, or part of, project development. In documentation we give our opinions on how to use Julia for project development focussing on Julia version control with the command line tool `juliaup`, typical patterns for using stacked environments and useful settings for development using the Julia extension of VS-Code as an interactive development environment (IDE) for Julia project. Please find the documentation [here](https://cdcgov.github.io/Rt-without-renewal/dev/man/getting-started-julia/).
