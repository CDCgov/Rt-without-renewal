# Frequently asked questions

This page contains a list of frequently asked questions about the `EpiAware` package. If you have a question that is not answered here, please open a discussion on the GitHub repository.

```@contents
Pages = ["lib/getting-started/faq.md"]
```

## Pluto scripts

We use [`Pluto.jl`](https://plutojl.org/) scripts as part of our documentation and testing. The scripts are located in `docs/src/examples` and can be run using the `Pluto.jl` package.
We recommend using the version of `Pluto` that is pinned in the `Project.toml` file defining the documentation environment.
An entry point to running or developing this documentation is the `docs/pluto-scripts.sh` bash shell script. Run this from the root directory of this repository.

## Manipulating `EpiAware` model specifications

### Specifying models which are components

#### Modular model construction

#### Remaking models

## Working with `Turing.jl` models

### Conditioning and fixing models

### Tools for working with `MCMCChain` objects

#### [`MCMCChain.jl`](https://turinglang.org/MCMCChains.jl/stable/)

[`MCMCChain.jl`](https://turinglang.org/MCMCChains.jl/stable/) is the package from which `MCMCChains` is imported. It provides a number of useful functions for working with `MCMCChain` objects. These include functions for summarising, plotting, and manipulating chains. Below is a list of some of the most useful functions.

- `plot`: Plots trace  and density plots for each parameter in the chain object.
- `histogram`: Plots histograms for each parameter in the chain object by chain.
- `get`: Accesses the values of a parameter/s in the chain object.
- `DataFrames.DataFrame` converts a chain into a wide format `DataFrame`.
- `describe`: Prints the summary statistics of the chain object.

There are many more functions available in the `MCMCChain.jl` package. For a full list of functions, see the [documentation](https://turinglang.org/MCMCChains.jl/stable/).

#### [`Arviz.jl`](https://julia.arviz.org/ArviZ/stable/)

An alternative to `MCMCChain.jl` is the `ArviZ.jl` package. `ArviZ.jl` is a Julia meta-package for exploratory analysis of Bayesian models. It is part of the ArviZ project, which also includes a related Python package.

`ArviZ.jl` uses a `InferenceData` object to store the results of a Bayesian analysis. This object can be created from a `MCMCChain` object using the `from_mcmcchains` function.
The `InferenceData` object can then be used to create a range of plots and summaries of the model.
This is particularly useful as it allows you to specify the indexes of your parameters (for example you could use dates for time parameters).

In addition to this useful functionality `from_mcmcchains` can also be used to combine posterior predictions with prior predictions, prior information and the log likelihood of the model (see [here](https://julia.arviz.org/ArviZ/stable/quickstart/) for an example of this).
This unlocks a range of useful diagnostics and plots that can be used to assess the model.

There is a lot of functionality in `ArviZ.jl` and it is worth exploring the [documentation](https://julia.arviz.org/ArviZ/stable/) to see what is available.
