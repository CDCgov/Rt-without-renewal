@testitem "SafeInt Type Tests" begin
    using Distributions
    struct DummySampleable <: Sampleable{Univariate, SafeIntValued} end

    @test SafeIntValued <: Distributions.ValueSupport
    @test eltype(DummySampleable) <: Union{Int, BigInt}
    @test SafeDiscreteUnivariateDistribution == Distribution{Univariate, SafeIntValued}
end
