# Interfaces

We support two primary workflows for using the package:

- `EpiProblem`: A high-level interface for defining and fitting models to data. This is the recommended way to use the package.
- `Turing` interface: A lower-level interface for defining and fitting models to data. This is the more flexible way to use the package and may also be more familiar to users of `Turing.jl`.

See the getting started section for tutorials on each of these workflows.

## EpiProblem

Each module of the overall epidemiological model we are interested in is a `Turing` `Model` in its own right. In this section, we compose the individual models into the full epidemiological model using the `EpiProblem` struct.

The constructor for an `EpiProblem` requires:

- An `epi_model`.
- A `latent_model`.
- An `observation_model`.
- A `tspan`.

The `tspan` set the range of the time index for the models.

## Turing interface

The `Turing` interface is a lower-level interface for defining and fitting models to data. This is the more flexible way to use the package and may also be more familiar to users of `Turing.jl`.
