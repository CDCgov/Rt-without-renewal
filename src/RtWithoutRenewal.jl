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
    Turing, LogExpFunctions, LinearAlgebra, SparseArrays, Random, ReverseDiff, Optim

export scan
    
include("utilities.jl")

end
