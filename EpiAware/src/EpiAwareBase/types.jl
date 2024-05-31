abstract type AbstractModel end

"""
The abstract supertype for all structs that define a model for generating
unobserved/latent infections.
"""
abstract type AbstractEpiModel <: AbstractModel end

"""
A abstract type representing a Turing-based epidemiological model.
"""
abstract type AbstractTuringEpiModel <: AbstractEpiModel end

"""
The abstract supertype for all structs that define a model for generating a latent process
used in `EpiAware` models.
"""
abstract type AbstractLatentModel <: AbstractModel end

"""
A abstract type representing a Turing-based Latent model.
"""
abstract type AbstractTuringLatentModel <: AbstractLatentModel end

"""
A abstract type used to define the common interface for intercept models.
"""
abstract type AbstractTuringIntercept <: AbstractTuringLatentModel end

"""
An abstract type representing a broadcast rule.
"""
abstract type AbstractBroadcastRule end

"""
A type representing an abstract observation model that is a subtype of `AbstractModel`.
"""
abstract type AbstractObservationModel <: AbstractModel end

"""
A abstract type representing a Turing-based observation model.
"""
abstract type AbstractTuringObservationModel <: AbstractObservationModel end

"""
Abstract supertype for all `EpiAware` problems.
"""
abstract type AbstractEpiProblem end

"""
Abstract supertype for all `EpiAware` inference/generative modelling methods.
"""
abstract type AbstractEpiMethod end

"""
Abstract supertype for infence/generative methods that are based on optimization, e.g. MAP estimation or variational inference.
"""
abstract type AbstractEpiOptMethod <: AbstractEpiMethod end

"""
Abstract supertype for infence/generative methods that are based on sampling
from the posterior distribution, e.g. NUTS.
"""
abstract type AbstractEpiSamplingMethod <: AbstractEpiMethod end

"""
Abstract type for all Renewal-based infection generating models.
"""
abstract type AbstractRenewal <: EpiAwareBase.AbstractTuringEpiModel end
