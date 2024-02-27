# EpiAware

[![SciML Code Style](https://img.shields.io/static/v1?label=code%20style&message=SciML&color=9558b2&labelColor=389826)](https://github.com/SciML/SciMLStyle)
[![Test EpiAware](https://github.com/CDCgov/Rt-without-renewal/actions/workflows/test-EpiAware.yaml/badge.svg)](https://github.com/CDCgov/Rt-without-renewal/actions/workflows/test-EpiAware.yaml)
[![codecov](https://codecov.io/gh/CDCgov/Rt-without-renewal/graph/badge.svg?token=IX4GIA8F0H)](https://codecov.io/gh/CDCgov/Rt-without-renewal)

## Model Diagram

- Solid lines indicate implemented features/analysis.
- Dashed lines indicate planned features/analysis.

## Current `EpiAware` model diagram
```mermaid
flowchart LR

A["Underlying GI
Bijector"]

EpiModel["AbstractEpiModel
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

LatentProc["AbstractLatentProcess
---------------------
RandomWalkLatentProcess"]

ObsModelPriors["Observation model priors
choice of delayed obs. model"]

ObsModel["AbstractObservationModel
---------------------
DelayObservations"]

E["Turing model constructor
---------------------
make_epi_inference_model"]

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
