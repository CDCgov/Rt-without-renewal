@testitem "Testing SafePoisson Constructor " begin
    λ = 10.0
    dist = SafePoisson(λ)
    @test typeof(dist) <: SafePoisson
end

@testitem "Check distribution properties of SafePoisson" begin
    using Distributions, HypothesisTests, StatsBase
    λ = 10.0
    dist = SafePoisson(λ)
    #Check Distributions.jl mean function
    @test mean(dist) ≈ λ
    samples = [rand(dist) for _ in 1:100_000]
    #Check mean from direct sampling of Distributions version and ANOVA and Variance F test comparisons
    direct_samples = rand(Poisson(λ), 100_000)
    mean_pval = OneWayANOVATest(samples, direct_samples) |> pvalue
    @test mean_pval > 1e-6 #Very unlikely to fail if the model is correctly implemented
    var_pval = VarianceFTest(samples, direct_samples) |> pvalue
    @test var_pval > 1e-6 #Very unlikely to fail if the model is correctly implemented
    @test isapprox(var(dist), var(direct_samples), atol = 0.1)

    @testset "Check quantiles" begin
        for q in [0.1, 0.25, 0.5, 0.75, 0.9]
            @test isapprox(quantile(dist, q), quantile(direct_samples, q), atol = 0.1)
        end
    end

    @testset "Check support boundaries" begin
        @test minimum(dist) == 0
        @test maximum(dist) == Inf
    end

    @testset "Check logpdf against Distributions" begin
        for x in 0:10:100
            @test isapprox(logpdf(dist, x),
                logpdf(Poisson(λ), x), atol = 0.1)
        end
    end

    @testset "Check CDF" begin
        x = 0:10:100
        @test isapprox(cdf(dist, x), ecdf(direct_samples)(x), atol = 0.05)
    end
end

@testitem "Testing safety of rand call for SafePoisson at large values" begin
    using Distributions
    bigλ = exp(48.0) #Large value of λ
    dist = SafePoisson(bigλ)
    @testset "Large value of mean samples a BigInt with SafePoisson" begin
        @test rand(dist) isa BigInt
    end
    @testset "Large value of mean sample failure with Poisson" begin
        _dist = Poisson(dist.λ)
        @test_throws InexactError rand(_dist)
    end
end
