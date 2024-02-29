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
  * Patch version [milestones](https://github.com/CDCgov/EpiAware/milestones) are used to keep track of which PRs get backported etc.

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
