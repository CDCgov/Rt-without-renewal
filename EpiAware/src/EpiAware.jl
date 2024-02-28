"""
    module EpiAware

`EpiAware` provides functionality for fitting epidemiological models to data. It is built on
     top of the `Turing` probabilistic programming language, and provides a set of utilities
     for constructing and fitting models to data.

## Core model structure

An epidemiological model in `EpiAware` consists of composable structs with core abstract
    types. The core types are:

1. `AbstractEpiModel`: Subtypes of this abstract type represent different models for the
     spread of an infectious disease. Each model type has a corresponding
     `make_epi_inference_model` function that constructs a `Turing` model for fitting the
         model to data. Implemented concrete subtypes:
    - `Renewal`: A renewal process model for the spread of an infectious disease.
    - `ExpGrowthRate`: An exponential growth rate model for the spread of an infectious
         disease.
    - `DirectInfections`: A model for the spread of an infectious disease based on modelling
        direct infections.
2. `AbstractLatentProcess`: Subtypes of this abstract type represent different latent
     processes that can be used in an epidemiological model. Implemented concrete subtype:
    - `RandomWalkLatentProcess`: A random walk latent process.
3. `AbstractObservationProcess`: Subtypes of this abstract type represent different
    observation processes that can be used in an epidemiological model.
    Implemented concrete subtypes:
    - `DelayObservation`: An observation process that models the delay between the time
        of infection and the time of observation as a convolution, followed by a negative
        binomial distributed sample.

## Imports

$(IMPORTS)

## Exports

$(EXPORTS)

"""
module EpiAware

using Distributions, Turing, LogExpFunctions, LinearAlgebra, SparseArrays, Random,
      ReverseDiff, Optim, Parameters, QuadGK, DataFramesMeta, DocStringExtensions

# Exported utilities
export create_discrete_pmf, spread_draws, scan

# Exported types
export EpiData, Renewal, ExpGrowthRate, DirectInfections, AbstractEpiModel

# Exported Turing model constructors
export make_epi_inference_model

include("epimodel.jl")
include("utilities.jl")
include("latent-processes.jl")
include("observation-processes.jl")
include("models.jl")

end
