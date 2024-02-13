"""
    EpiAware

This module provides functionality for calculating Rt (effective reproduction number) with and without
    considering renewal processes.

# Dependencies

- Distributions: for working with probability distributions.
- Turing: for probabilistic programming.
- LogExpFunctions: for working with logarithmic, logistic and exponential functions.
- LinearAlgebra: for linear algebra operations.
- SparseArrays: for working with sparse arrays.
- Random: for generating random numbers.
- ReverseDiff: for automatic differentiation.
- Optim: for optimization algorithms.
- Zygote: for automatic differentiation.

"""
module EpiAware

using Distributions,
    Turing,
    LogExpFunctions,
    LinearAlgebra,
    SparseArrays,
    Random,
    ReverseDiff,
    Optim,
    Parameters,
    QuadGK

export scan,
    create_discrete_pmf,
    growth_rate_to_reproductive_ratio,
    generate_observation_kernel,
    EpiModel,
    log_infections,
    random_walk

include("utilities.jl")
include("epimodel.jl")
include("models.jl")
include("latent-processes.jl")

end
