"""
    RtWithoutRenewal

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
module RtWithoutRenewal

using Distributions,
    Turing,
    LogExpFunctions,
    LinearAlgebra,
    SparseArrays,
    Random,
    ReverseDiff,
    Optim,
    Parameters

export scan,
    create_discrete_pmf, growth_rate_to_reproductive_ratio, EpiModel, log_daily_infections

include("utilities.jl")
include("epimodel.jl")
include("models.jl")

end
