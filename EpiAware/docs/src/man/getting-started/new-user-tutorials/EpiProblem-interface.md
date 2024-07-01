# Getting Started: EpiProblem Interface

Each module of the overall epidemiological model we are interested in is a `Turing` `Model` in its own right. In this section, we compose the individual models into the full epidemiological model using the `EpiProblem` struct.

The constructor for an `EpiProblem` requires:

- An `epi_model`.
- A `latent_model`.
- An `observation_model`.
- A `tspan`.

The `tspan` set the range of the time index for the models.

The diagram below shows the relationship between the modules in the package for a typical workflow.

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
