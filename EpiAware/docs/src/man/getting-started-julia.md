# Getting Started with using Julia in Projects

Julia is a programming language aimed at technical computing. This guide is aimed at helping you set up Julia on your system according to our recommended best practices.

If you are familar with other languages with tooling for technical computing (e.g. `R`, `MATLAB`, `Python`) these [noteworthy differences](https://docs.julialang.org/en/v1/manual/noteworthy-differences/) may be useful.

**Table of Contents**
- [Julia Installation with Juliaup](#julia-installation-with-juliaup)
- [Basic usage of Juliaup](#basic-usage-of-juliaup)
- [Basic usage for Julia environments](#basic-usage-for-julia-environments)
- [Using the Julia REPL in projects](#using-the-julia-repl-in-projects)
- [Recommended packages for the "global" Julia version environment](#recommended-packages-for-the-global-julia-version-environment)
- [Developing a Julia project from VS-Code](#developing-a-julia-project-from-vs-code)
- [Literate programming with Julia](#literate-programming-with-julia)

## What this guide is and isn't
This isn't a guide to learning the Julia programming language. Instead we providing an opinionated guide to setting up your system to use Julia effectively in project workflows aimed at people with familiarity with Julia but have maybe only developed projects in other languages (e.g. `R`, `MATLAB`, `Python`).

If you want to learn more about the Julia programming language, we recommend the following resources:

- [Julia Documentation - getting started](https://docs.julialang.org/en/v1/manual/getting-started/).
- [Julia Academy](https://juliaacademy.com/).
- [Julia learning resources](https://julialang.org/learning/).
- [JuliaHub](https://juliahub.com/).
- [Julia Discourse](https://discourse.julialang.org/).
- [Julia Slack](https://julialang.slack.com/).

## Julia Installation with Juliaup

1. **Download Juliaup**: This is a cross-platform installer/updater for the Julia programming language. It simplifies the process of installing and managing Julia versions. Go to the [Juliaup GitHub repository](https://github.com/JuliaLang/juliaup) or to the [official Julia website](https://julialang.org/downloads/) for installation instructions.
2. **Verify Installation**: Open a terminal (or Command Prompt on Windows) and type `julia` to start the Julia REPL (Read-Eval-Print Loop). You should see a Julia prompt `julia>`.


## Basic usage of Juliaup

Juliaup is a tool for managing Julia installations on your system. It allows you to install, update, and switch between different versions of Julia. Details are available at the [Juliaup GitHub repository](https://github.com/JuliaLang/juliaup), but here are some examples of common commands:

### Add a specfic version of Julia

Juliaup default installs the latest release version of Julia. To install a specific version, use the `add` command followed by the version number. For example, to install Julia version 1.9.3, use the following command:

```bash
% juliaup add 1.9.3
```

### Use a specific version of Julia

To switch between different versions of Julia, use `+ julia-version` after the `julia` command. For example, to use Julia version 1.9.3, use the following command:

```bash
% julia +1.9.3
```

This will use the specified version of Julia for the current REPL. In general, adding the `+ julia-version` flag after the `julia` command will execute using the specified version of Julia.

### Check versions of Julia installed

To see a list of all the versions of Julia installed on your system, use the following command:

```bash
% juliaup list
```

### Update Julia (all versions installed)
This will update all versions of Julia installed on your system to their latest release versions.

```bash
% juliaup update
```

##  Basic usage for Julia environments

The [_environment_](https://docs.julialang.org/en/v1/manual/code-loading/#Environments-1) of a Julia project determines which packages, and their version, are available to the project. This is useful when you want to ensure that a project uses a specific version of a package, or when you want to isolate the project from other projects on your system. As per other languages, Julia environments are useful for managing dependencies and ensuring reproducibility.

The most common usage of environments is to create a new [_explicit_ environment](https://docs.julialang.org/en/v1/manual/code-loading/#Environments) for a project in a directory. This creates a `Project.toml` file in the directory that specifies the dependencies for the project and a `Manifest.toml` file that specifies the exact versions of the dependencies, and their underlying dependencies. We'll discuss how to set up a new environment for a project in the [REPL section](#using-the-julia-repl).

Julia environments can be [stacked](https://docs.julialang.org/en/v1/manual/code-loading/#Environment-stacks). This means that you can have a _primary_ environment embedded in the stacked environment, along with _secondary_ environment(s) that define common packages to be available to many projects.

From a project development point of view, most commonly the project environment will be the primary environment, isolated from other project environments. And the environment of the Julia version installation (e.g. the `@v1.10` env) will be a secondary environment because its in the default `LOAD_PATH` [Julia environmental variable](https://docs.julialang.org/en/v1/manual/environment-variables/#Environment-Variables). You can add packages to the Julia version environment that you want to be available to all projects as we'll show in the [REPL section](#using-the-julia-repl). See section [Recommended packages for the primary Julia environment](#recommended-packages-for-the-primary-julia-environment) for our recommendations.

## Using the Julia REPL in projects

The Julia REPL (Read-Eval-Print Loop) is an interactive programming environment that takes single user inputs (i.e., single expressions), evaluates them, and returns the result to the user.

### Package management programmatically and from REPL

Julia has a built-in package manager called `Pkg`, which is documented briefly [here](https://docs.julialang.org/en/v1/stdlib/Pkg/) and in more detail [here](https://pkgdocs.julialang.org/v1/). The package manager is used to install, update, and manage Julia packages and environments.

You can use `Pkg` programmatically as a normal Julia package, which is often done in scripts. For example, if we wanted to install the `OrdinaryDiffEq` package as part of executing a julia script, we would add the following lines to the script:

```julia
using Pkg
Pkg.add("OrdinaryDiffEq")
```

However, you can also use the package manager interactively from the REPL. In our opinion, this is the more common usage of package management in Julia project development.

For example, to install the `OrdinaryDiffEq` package from the REPL you can switch to package mode by typing `]` and then type `add OrdinaryDiffEq`. To exit package mode, type `backspace`.

```julia-repl
julia> ]
(@v1.10) pkg> add OrdinaryDiffEq
```

This workflow is often more convenient than the programmatic interface, especially when setting packages you want to install to the environment for your julia installation, e.g the `@v1.10` environment for julia 1.10.

By default, the environment for a julia installation is [stacked](https://docs.julialang.org/en/v1/manual/code-loading/#Environment-stacks) as a primary environment, so that the packages you install in the julia installation environment are available to all projects.

### Using the Julia REPL to set up active project environments

To set a new active project environment, you can use the `Pkg` package manager from the REPL with the command `activate` with a local directory path. The project environment is named after the directory hosting the `Project.toml` file. After activating the project environment, you can manage packages to the project environment, as well as use packages from the primary stacked environment as described above.

Here is an example of how you can create a new environment for a project when the REPL working directory is in some directory `/myproject`, and then add `OrdinaryDiffEq` to the project environment:

```julia-repl
julia> pwd() #Check your directory
# "path/to/myproject"
julia> ]
(@v1.10) pkg> activate .
(myproject) pkg> add OrdinaryDiffEq
```

Note that if the project directory doesn't have a `Project.toml` file, one will be created when you add the first package to the project environment.

### Experimenting with Julia from REPL using a temporary environment

It is quite common to want to experiment with new Julia packages and code snippets. A convenient way to do this without setting up a new project environment or adding dependencies to the primary environment is to use a temporary environment. To do this:

```julia-repl
julia> ]
(@v1.10) pkg> activate --temp
(jl_FTIz6j) pkg> add InterestingPackage
```

This will create a temporary environment, stacked with the primary environment, that is not saved to disk, and you can add packages to this environment without affecting the primary environment or any project environments. When you exit the REPL, the temporary environment will be deleted.

## Recommended packages for the "global" Julia version environment

In our view these packages are useful for your Julia version environment, e.g. `v1.10` env, which will be available to other environments.

- `Revise`: For modifying package code and using the changes without restarting Julia session.
- `Term`: For pretty and stylized REPL output (including error messages).
- `JuliaFormatter`: For code formatting.
- `Documenter`: For local documentation generation.
- `Pluto`: A native Julia notebook for interactive development.
- `TestEnv`: For easy use of test environments for package testing.
- `UnicodePlots`: For simple and quick plotting in the REPL without needing to install a fully featured plotting package.

## Developing a Julia project from VS-Code

### Julia extension for VS-Code
Visual Studio Code (VS-Code) is a popular code editor that supports Julia development. The [Julia extension for VS-Code](https://www.julia-vscode.org/) provides an interactive development environment that will be familiar to users of other scientific IDEs (e.g. developing `R` projects in RStudio or using the `MATLAB` application).

### Features of the Julia extension for VS-Code
It is worth reading both the [VS-Code documentation](https://code.visualstudio.com/docs/languages/julia) and the [Julia extension documentation](https://www.julia-vscode.org/docs/stable/), however, here are some highlights:

- **Julia REPL**: The Julia extension provides an integrated REPL in the `TERMINAL` pane that allows you to interact with Julia code directly from the editor. For example, you can run code snippets from highlighting or code blocks defined by `##` comments in the scripts.
- **Plotting**: By default, plots generated by featured plotting packages (e.g. `Plots.jl`) will be displayed in a Plot pane generated by the VS-Code editor.
- **Julia Tab**: The Julia extension provides a Julia tab with the following sub-tabs:
  - **Workspace**: This allows you to inspect the modules, functions and variables in your current REPL session. For variables that can be understood as a [Table](https://www.julia-vscode.org/docs/stable/userguide/grid/), you can view them in a tabular format from the workspace tab.
  - **Documentation**: This allows you to view the documentation for functions and types in the Julia standard library and any packages you have installed.
  - **Plot Navigator**: This allows you to navigate the plots generated by the featured plotting packages.
- **Testing**: The Julia extension provides interaction between the `Testing` tab in VS-Code with Julia tests defined using the Julia package `TestItems` macro `@testitem` run with `TestItemRunner`.

Other standard IDE features are **Code completion**, **Code linting**, **Code formatting**, **Debugging**, and **Profiling**.

### Recommended settings for the Julia extension in VS-Code

The settings of the Julia extension can be found by accessing `Preferences: Open User Settings` from the command palette in VS-Code and then searching for `Julia`.

We recommend the following workplace settings saved in a file `.vscode/settings.json` relative to your working directory:

```json
{
    "[julia]": {
        "editor.detectIndentation": false,
        "editor.insertSpaces": true,
        "editor.tabSize": 4,
        "files.insertFinalNewline": true,
        "files.trimFinalNewlines": true,
        "files.trimTrailingWhitespace": true,
        "editor.rulers": [80],
        "files.eol": "\n"
    },
    "julia.liveTestFile": "path/to/runtests.jl",
    "julia.environmentPath": "path/to/project/directory",
}
```

These settings set basic code formatting and whitespace settings for Julia files, as well as setting the path to the test file for the project and the path to the project directory for the environment.

The `VS-Code` command `Julia: Start REPL` will start a REPL in `TERMINAL` tab in the editor with the environment set to the project directory and the `Testing` tab will detect the defined tests for the project.


## Literate programming with Julia

Its common to develop technical computing projects using a literate programming style, where code and documentation are interwoven. Julia supports this style of programming through a number of packages:

- `Pluto`: A native Julia notebook for interactive development. `Pluto` notebooks are reactive, meaning that the output of all cells are updated as input changes. Installation instructions are available [here](https://github.com/fonsp/Pluto.jl). Pluto notebook files have the extension `.jl` and can be run as scripts.
- `IJulia`: A Julia kernel for Jupyter notebooks. Installation instructions are available [here](https://github.com/JuliaLang/IJulia.jl). A useful package for integrating `.ipynb` into a workflow is [`NBInclude.jl`](https://github.com/JuliaInterop/NBInclude.jl) which allows you to include the variables/output of a `.ipynb` notebook into a Julia script.
- `Quarto`: [A multi-language scientific publishing system](https://quarto.org/). Quarto interfaces with Julia via `IJulia` kernel for jupyter. Julia code blocks are executed and the output is included with the markdown output in document generation. Installation instructions are available [here](https://quarto.org/docs/get-started/index.html).
- `Weave`: A package for literate programming in Julia. `Weave` allows you to write a `.jmd` file that contains both markdown and Julia code. The Julia code is executed and the output is included in the markdown output. In our view, `Weave` is superceded by Quarto usage.
