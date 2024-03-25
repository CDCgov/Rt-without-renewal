@testitem "Testing HalfNormal Constructor " begin
    prior_mean = 10.0
    prior_dist = HalfNormal(prior_mean)
    @test typeof(prior_dist) <: HalfNormal
end

@testitem "Check distribution properties of HalfNormal" begin
    using Distributions, HypothesisTests, StatsBase
    prior_mean = 2.0
    prior_dist = HalfNormal(prior_mean)
    #Check Distributions.jl mean function
    @test mean(prior_dist) ≈ prior_mean
    samples = rand(prior_dist, 100_000)
    #Check mean from direct sampling of folded distribution and ANOVA and Variance F test comparisons
    direct_samples = randn(100_000) * prior_mean * sqrt(pi) / sqrt(2) .|> abs
    mean_pval = OneWayANOVATest(samples, direct_samples) |> pvalue
    @test mean_pval > 1e-6 #Very unlikely to fail if the model is correctly implemented
    var_pval = VarianceFTest(samples, direct_samples) |> pvalue
    @test var_pval > 1e-6 #Very unlikely to fail if the model is correctly implemented
    @test isapprox(var(prior_dist), var(direct_samples), atol = 0.1)

    @testset "Check quantiles" begin
        for q in [0.1, 0.25, 0.5, 0.75, 0.9]
            @test isapprox(quantile(prior_dist, q), quantile(direct_samples, q), atol = 0.1)
        end
    end

    @testset "Check support boundaries" begin
        @test minimum(prior_dist) == 0.0
        @test maximum(prior_dist) == Inf
    end

    @testset "Check logpdf" begin
        for x in [0.0, 1.0, 2.0, 3.0, 4.0]
            @test isapprox(logpdf(prior_dist, x),
                logpdf(Normal(0, prior_mean * sqrt(π / 2)), x) - log(2), atol = 0.1)
        end
    end

    @testset "Check CDF" begin
        x = 1:10
        @test isapprox(cdf(prior_dist, x), ecdf(direct_samples)(x), atol = 0.05)
    end
end
