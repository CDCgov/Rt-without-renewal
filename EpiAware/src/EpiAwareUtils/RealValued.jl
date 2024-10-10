"""
A type to represent real-valued distributions, the purpose of this type is to avoid problems
with the `eltype` function when having `rand` calls in the model.
"""
struct RealValued <: Distributions.ValueSupport end
Base.eltype(::Type{<:Sampleable{F,RealValued}}) where {F} = Real

"""
A constant alias for `Distribution{Univariate, RealValued}`. This type represents a univariate distribution with real-valued outcomes.
"""
const RealUnivariateDistribution = Distribution{Univariate, RealValued}
