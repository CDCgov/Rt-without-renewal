# Frequently asked questions

This page contains a list of frequently asked questions about the `EpiAware` package. If you have a question that is not answered here, please open a discussion on the GitHub repository.

```@contents
Pages = ["lib/getting-started/faq.md"]
```

## Pluto notebooks

In some of the showcase examples in `EpiAware/docs/src/showcase` we use [`Pluto.jl`](https://plutojl.org/) notebooks for the underlying computation. As well as reading the code blocks and output of the notebooks in this documentation, you can also run these notebooks by cloning `EpiAware` and running the notebooks with `Pluto.jl` (for further details see [contributing](@ref contributing)).

It should be noted that `Pluto.jl` notebooks are reactive, meaning that they re-run downstream code after changes with downstreaming determined by a tree of dependent code blocks. This is different from the standard Julia REPL, and some other notebook formats (e.g. `.ipynb`). In `Pluto` each code block is a single lines of code or encapsulated by `let ... end` and `begin ... end`. The difference between `let ... end` blocks and `begin ... end` blocks are that the `let ... end` type of code block only adds the final output/return value of the block to scope, like an anonymous function, whereas `begin ... end` executes each line and adds defined variables to scope.

For installation instructions and more information and documentation on `Pluto.jl` see the [Pluto.jl documentation](https://plutojl.org/).


## Manipulating `EpiAware` model specifications

### Modular model construction

One of the key features of `EpiAware` is the ability to specify models as components of a larger model.
This is useful for specifying models that are shared across multiple `EpiProblems` or for specifying models that are used in multiple methods.
You can see an examples of this approach in our [showcases](@ref showcase).

### Remaking models

An alternative to modular model construction is to remake models with different parameters. This can be useful for comparing models with different parameters or for comparing models with different priors.
Whilst we don't have a built in function for this, we recommend the `Accessors.jl` package for this purpose.
For examples of how to use this package see the [documentation](https://juliaobjects.github.io/Accessors.jl/stable/getting_started/).

## Working with `Turing.jl` models

### [`DynamicPPL.jl`](https://github.com/TuringLang/DynamicPPL.jl)

Whilst `Turing.jl` is the front end of the `Turing.jl` ecosystem, it is not the only package that can be used to work with `Turing.jl` models. [`DynamicPPL.jl`](https://github.com/TuringLang/DynamicPPL.jl) is the part of the ecosytem that deals with defining, running, and manipulating models.

#### Conditioning and deconditioning models

`DynamicPPL` supports the `condition` (alased with `|`) to fix values as known *observations* in the model (i.e fixing values on the left hand side of `~` definitions).
This is useful for fixing parameters to known values or for conditioning the model on data.
The `decondition` function can be used to remove these conditions.
Internally this is what [`apply_method(::EpiProblem, ...)`](https://cdcgov.github.io/Rt-without-renewal/dev/lib/EpiAwareBase/public/#EpiAware.EpiAwareBase.apply_method-Tuple%7BEpiProblem,%20AbstractEpiMethod,%20Any%7D) does to condition the user supplied `EpiProblem` to data. See more [here](https://turinglang.org/DynamicPPL.jl/stable/tutorials/prob-interface/#Conditioning-and-Deconditioning).

#### Fixing and unfixing models

Similarly to conditioning and deconditioning models, `DynamicPPL` supports fixing and unfixing models via the `fix` and `unfix` functions.
Fixing is essentially saying that variables are constants (i.e replacing the right hand side of `~` with a value and changing the `~` to a `=`).
A common use of this would be to simplify a prespecified model, for example to make the variance of a random walk be known versus estimated from the data.
We also use this functionality in [`apply_method(::EpiProblem, ...)`](https://cdcgov.github.io/Rt-without-renewal/dev/lib/EpiAwareBase/public/#EpiAware.EpiAwareBase.apply_method-Tuple%7BEpiProblem,%20AbstractEpiMethod,%20Any%7D) to allow users to simplify `EpiProblems` on the fly. See more [here](https://turinglang.org/DynamicPPL.jl/stable/api/#DynamicPPL.fix).

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
