"""
    module EpiAware

`EpiAware` provides functionality for fitting epidemiological models to data. It is built on
     top of the `Turing` probabilistic programming language, and provides a set of utilities
     for constructing and fitting models to data.

## Core model structure

An epidemiological model in `EpiAware` consists of composable structs with core abstract
    types. The core types are:
1. `AbstractModel`: This overarching type is used to abstract `Turing` models and is inheried by the other abstract types we use.
2. `AbstractEpiModel`: Subtypes of this abstract type represent different models for the
     spread of an infectious disease. Each model type has a corresponding
     `make_epi_aware` function that constructs a `Turing` model for fitting the
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
    observation models that can be used in an epidemiological model.
    Implemented concrete subtypes:
    - `DelayObservation`: An observation process that models the delay between the time
        of infection and the time of observation as a convolution, followed by a negative
        binomial distributed sample.

"""
module EpiAware

include("EpiAwareBase/EpiAwareBase.jl")
import .EpiAwareBase: AbstractModel, AbstractEpiModel, AbstractLatentModel,
                      AbstractObservationModel

export AbstractModel, AbstractEpiModel, AbstractLatentModel,
       AbstractObservationModel, generate_latent,
       generate_latent_infs, generate_observations

include("EpiModels/EpiModels.jl")
using .EpiModels

export EpiData, DirectInfections, ExpGrowthRate, Renewal,
       R_to_r, r_to_R, create_discrete_pmf, default_rw_priors

include("InferenceMethods/InferenceMethods.jl")
using .InferenceMethods

export manypathfinder

include("LatentModels/LatentModels.jl")
using .LatentModels

export RandomWalk, default_delay_obs

include("ObservationModels/ObservationModels.jl")
using .ObservationModels

export DelayObservations, default_delay_obs

include("EpiAwareUtils/EpiAwareUtils.jl")
using .EpiAwareUtils

export spread_draws, scan

# Non-submodule imports
using Turing, DocStringExtensions

# Non-submodule exports
export make_epi_aware

include("docstrings.jl")
include("make_epi_aware.jl")

end
