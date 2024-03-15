abstract type AbstractModel end

"""
    abstract type AbstractEpiModel <: AbstractModel end

The abstract supertype for all structs that define a model for generating unobserved/latent
    infections.
"""
abstract type AbstractEpiModel <: AbstractModel end

abstract type AbstractLatentModel <: AbstractModel end

abstract type AbstractObservationModel <: AbstractModel end

"""
Abstract supertype for all `EpiAware` problems.
"""
abstract type AbstractEpiAwareProblem end
