const SafeInt = Union{Int, BigInt}

"""
A type to represent real-valued distributions, the purpose of this type is to avoid problems
with the `eltype` function when having `rand` calls in the model.
"""
struct SafeIntValued <: Distributions.ValueSupport end
function Base.eltype(::Type{<:Distributions.Sampleable{F, SafeIntValued}}) where {F}
    Union{Int, BigInt}
end

"""
A constant alias for `Distribution{Univariate, RealValued}`. This type represents a univariate distribution with real-valued outcomes.
"""
const SafeDiscreteUnivariateDistribution = Distributions.Distribution{
    Distributions.Univariate, SafeIntValued}
