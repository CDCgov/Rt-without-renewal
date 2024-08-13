@testitem "Testing SafeNegativeBinomial Constructor " begin
    μ = 10.0
    α = 0.05
    dist = SafeNegativeBinomial(μ, α)
    @test typeof(dist) <: SafeNegativeBinomial
end

@testitem "Check distribution properties of SafeNegativeBinomial" begin
    using Distributions, HypothesisTests, StatsBase
    μ = 10.0
    α = 0.05
    dist = SafeNegativeBinomial(μ, α)
    #Check Distributions.jl mean function
    @test mean(dist) ≈ μ
    @test var(dist) ≈ μ + α^2 * μ^2
    samples = [rand(dist) for _ in 1:100_000]
    #Check mean from direct sampling of Distributions version and ANOVA and Variance F test comparisons
    _dist = EpiAware.EpiAwareUtils._negbin(dist)
    direct_samples = rand(_dist, 100_000)
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
                logpdf(_dist, x), atol = 0.1)
        end
    end

    @testset "Check CDF" begin
        x = 0:10:100
        @test isapprox(cdf(dist, x), ecdf(direct_samples)(x), atol = 0.05)
    end
end

@testitem "Testing safety of rand call for SafeNegativeBinomial at large values" begin
    using Distributions
    bigμ = exp(48.0) #Large value of λ
    α = 0.05
    dist = SafeNegativeBinomial(bigμ, α)
    @testset "Large value of mean samples a BigInt with SafePoisson" begin
        @test rand(dist) isa BigInt
    end
    @testset "Large value of mean sample failure with Poisson" begin
        _dist = EpiAware.EpiAwareUtils._negbin(dist)
        @test_throws InexactError rand(_dist)
    end
end
