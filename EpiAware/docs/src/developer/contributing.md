# Contributing

This page details the some of the guidelines that should be followed when contributing to this package. It is adapted from `Documenter.jl`.

## Branches

`release-*` branches are used for tagged minor versions of this package. This follows the same approach used in the main Julia repository, albeit on a much more modest scale.

Please open pull requests against the `master` branch rather than any of the `release-*` branches whenever possible.

### Backports

Bug fixes are backported to the `release-*` branches using `git cherry-pick -x` by a EpiAware member and will become available in point releases of that particular minor version of the package.

Feel free to nominate commits that should be backported by opening an issue. Requests for new point releases to be tagged in `METADATA.jl` can also be made in the same way.

### `release-*` branches

* Each new minor version `x.y.0` gets a branch called `release-x.y` (a [protected branch](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)).
* New versions are usually tagged only from the `release-x.y` branches.
* For patch releases, changes get backported to the `release-x.y` branch via a single PR with the standard name "Backports for x.y.z" and label ["Type: Backport"](https://github.com/JuliaDocs/Documenter.jl/pulls?q=label%3A%22Type%3A+Backport%22). The PR message links to all the PRs that are providing commits to the backport. The PR gets merged as a merge commit (i.e. not squashed).
* The old `release-*` branches may be removed once they have outlived their usefulness.
* Patch version [milestones](https://github.com/CDCgov/Rt-without-renewal/milestones) are used to keep track of which PRs get backported etc.

## Style Guide

Follow the style of the surrounding text when making changes. When adding new features please try to stick to the following points whenever applicable. This project follows the
[SciML style guide](https://github.com/SciML/SciMLStyle).

## Tests

### Unit tests

As is conventional for Julia packages, unit tests are located at `test/*.jl` with the entrypoint
`test/runtests.jl`.

### End to end testing

Tests that build example package docs from source and inspect the results (end to end tests) are
located in `/test/examples`. The main entry points are `test/examples/make.jl` for building and
`test/examples/test.jl` for doing some basic checks on the generated outputs.

## Pluto usage in showcase documentation

Some of the showcase examples in `EpiAware/docs/src/showcase` use [`Pluto.jl`](https://plutojl.org/) notebooks for the underlying computation. The output of the notebooks is rendered into HTML for inclusion in the documentation in two steps:
1. [`PlutoStaticHTML.jl`](https://github.com/rikhuijzer/PlutoStaticHTML.jl) converts the notebook with output into a machine-readable `.md` format.
2. [`Documenter.jl`](https://github.com/JuliaDocs/Documenter.jl) renders the `.md` file into HTML for inclusion in the documentation during the build process.

For other examples of using `Pluto` to generate documentation see the examples shown [here](https://plutostatichtml.huijzer.xyz/stable/#Documenter.jl).

### Running Pluto notebooks from `EpiAware` locally

To run the `Pluto.jl` scripts in the `EpiAware` documentation directly from the source code you can do these steps:

1. Install [`Pluto.jl`](https://plutojl.org/) locally. We recommend using the version of `Pluto` that is pinned in the `Project.toml` file defining the documentation environment.
2. Clone the `EpiAware` repository.
3. Start `Pluto.jl` either from REPL (see the `Pluto.jl` documentation) or from the command line with the shell script `EpiAware/docs/pluto-scripts.sh`.
4. From the `Pluto.jl` interface, navigate to the `Pluto.jl` script you want to run.

### Contributing to Pluto notebooks in `EpiAware` documentation

#### Modifying an existing Pluto notebook
Committing changes to the `Pluto.jl` notebooks in the `EpiAware` documentation is the same as committing changes to any other part of the repository. However, please note that we expect the following features for the environment management of the notebooks:

1. Use the environment determined by the `Project.toml` file in the `EpiAware/docs` directory. If you want extra packages, add them to this environment.
2. Use the version of `EpiAware` that is used in these notebooks to be the version of `EpiAware` on the branch being pull requested into `main`. To do this use the `Pkg.develop` function.

To do this you can use the following code snippet in the Pluto notebook:

```julia
# Determine the relative path to the `EpiAware/docs` directory
docs_dir = dirname(dirname(dirname(dirname(@__DIR__))))
# Determine the relative path to the `EpiAware` package directory
pkg_dir = dirname(docs_dir)

using Pkg: Pkg
Pkg.activate(docs_dir)
Pkg.develop(; path = pkg_dir)
Pkg.instantiate()
```

#### Adding a new Pluto notebook
Adding a new `Pluto.jl` notebook to the `EpiAware` documentation is the same as adding any other file to the repository. However, in addition to following the guidelines for modifying an [existing notebook](#modifying-an-existing-pluto-notebook), please note that the new notebook is added to the set of notebook builds using `build` in the `EpiAware/docs/make.jl` file. This will generate an `.md` of the same name as the notebook which can be rendered when `makedocs` is run. For this document to be added to the overall documentation the path to the `.md` file must be added to the `Pages` array defined in `EpiAware/docs/pages.jl`.
