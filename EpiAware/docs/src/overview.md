[Overview of the EpiAware Software Ecosystem](@id overview)

_`EpiAware`  is not a standard toolkit for infectious disease modelling._

It seeks to be highly modular and composable for advanced users whilst still providing opinionated workflows for those who are new to the field. Developed by the authors behind other widely used infectious disease modelling packages such as `EpiNow2`, `epinowcast`, and `epidist`, alongside experts in infectious disease modelling in Julia,`EpiAware` is designed to go beyond the capabilities of these packages by providing a more flexible and extensible framework for modelling and inference of infectious disease dynamics.

## Package Features

- **Flexible**: The package is designed to be flexible and extensible, and to provide a consistent interface for fitting and simulating models.
- **Modular**: The package is designed to be modular, with a clear separation between the model and the data.
- **Extensible**: The package is designed to be extensible, with a clear separation between the model and the data.
- **Consistent**: The package is designed to provide a consistent interface for fitting and simulating models.
- **Efficient**: The package is designed to be efficient, with a clear separation between the model and the data.

## Package structure

`EpiAware.jl` is a wrapper around a series of submodules, each of which provides a different aspect of the package's functionality (much like the `tidyverse` in `R`). The package is designed to be modular, with a clear separation between modules and between modules and data. Currently included modules are:

- `EpiAwareBase`: The core module, which provides the underlying abstract types and functions for the package.
- `EpiAwareUtils`: A utility module, which provides a series of utility functions for working with the package.
- `EpiInference`: An inference module, which provides a series of functions for fitting models to data. Builds on top of `Turing.jl`.
- `EpiInfModels`: Provides tools for composing models of the disease transmission process. Builds on top of `Turing.jl`, in particular the `DynamicPPL.jl` interface.
- `EpiLatentModels`: Provides tools for composing latent models such as random walks, autoregressive models, etc. Builds on top of `DynamicPPL.jl`. Used by all other modelling modules to define latent processes.
- `EpiObsModels`: Provides tools for composing observation models, such as Poisson, Binomial, etc. Builds on top of `DynamicPPL.jl`.

## Using the package

We support two primary workflows for using the package:

- `EpiProblem`: A high-level interface for defining and fitting models to data. This is the recommended way to use the package.
- `Turing` interface: A lower-level interface for defining and fitting models to data. This is the more flexible way to use the package and may also be more familiar to users of `Turing.jl`.

See the getting started section for tutorials on each of these workflows.
