"""
    module EpiAware

`EpiAware` provides functionality for fitting epidemiological models to data. It is built on
     top of the `Turing` probabilistic programming language, and provides a set of utilities
     for constructing and fitting models to data.

## Core model structure

An epidemiological model in `EpiAware` consists of composable structs with core abstract
    types. The core types are:
1. `AbstractModel`: This overarching type is used to abstract `Turing` models and is inheried by the other abstract types we use.
``
2. `AbstractEpiModel`: Subtypes of this abstract type represent different models for the
     spread of an infectious disease. Each model type has a corresponding
     `make_epi_inference_model` function that constructs a `Turing` model for fitting the
         model to data. Implemented concrete subtypes:
    - `Renewal`: A renewal process model for the spread of an infectious disease.
    - `ExpGrowthRate`: An exponential growth rate model for the spread of an infectious
         disease.
    - `DirectInfections`: A model for the spread of an infectious disease based on modelling
        direct infections.
3. `AbstractLatentModel`: Subtypes of this abstract type represent different latent
     processes that can be used in an epidemiological model. Implemented concrete subtype:
    - `RandomWalk`: A random walk latent process.
4. `AbstractObservationModel`: Subtypes of this abstract type represent different
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
export EpiData, Renewal, ExpGrowthRate, DirectInfections, AbstractEpiModel,
       AbstractLatentModel, AbstractObservationModel

# Exported Turing model constructors
export make_epi_aware

include("abstract-types.jl")
include("epi-models.jl")
include("utilities.jl")
include("latent-models.jl")
include("observation-models.jl")
include("models.jl")

end
