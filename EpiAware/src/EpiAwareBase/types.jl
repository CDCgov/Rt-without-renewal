abstract type AbstractModel end

"""
The abstract supertype for all structs that define a model for generating unobserved/latent
infections.
"""
abstract type AbstractEpiModel <: AbstractModel end

"""
The abstract supertype for all structs that define a model for generating a latent process
used in `EpiAware` models.
"""
abstract type AbstractLatentModel <: AbstractModel end

abstract type AbstractObservationModel <: AbstractModel end

"""
Abstract supertype for all `EpiAware` problems.
"""
abstract type AbstractEpiProblem end

"""
Abstract supertype for all `EpiAware` inference/generative modelling methods.
"""
abstract type AbstractEpiMethod end

"""
Abstract supertype for infence/generative methods that are based on optimization, e.g. MAP
estimation or variational inference.
"""
abstract type AbstractEpiOptMethod <: AbstractEpiMethod end

"""
Abstract supertype for infence/generative methods that are based on sampling from the
posterior distribution, e.g. NUTS.
"""
abstract type AbstractEpiSamplingMethod <: AbstractEpiMethod end
