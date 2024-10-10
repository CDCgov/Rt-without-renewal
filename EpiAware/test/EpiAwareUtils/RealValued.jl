@testitem "RealValued Type Tests" begin
    using Distributions
    struct DummySampleable <: Sampleable{Univariate, RealValued} end

    @test RealValued <: Distributions.ValueSupport
    @test eltype(DummySampleable) == Real
    @test RealUnivariateDistribution == Distribution{Univariate, RealValued}
end
