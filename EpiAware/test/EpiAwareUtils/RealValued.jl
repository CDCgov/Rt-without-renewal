@testitem "RealValued Type Tests" begin
    @test RealValued <: Distributions.ValueSupport
end

# Test for eltype function
@testitem "eltype Function Tests" begin
    struct DummySampleable <: Sampleable{Univariate, RealValued} end
    @test eltype(DummySampleable) == Real
end

# Test for RealUnivariateDistribution alias
@testitem "RealUnivariateDistribution Alias Tests" begin
    @test RealUnivariateDistribution == Distribution{Univariate, RealValued}
end
