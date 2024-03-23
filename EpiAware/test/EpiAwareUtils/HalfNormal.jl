@testitem "Testing HalfNormal" begin
    using Distributions, HypothesisTests
    @testset "Check distribution type" begin
        prior_mean = 10.0
        prior_dist = EpiAware.EpiLatentModels.HalfNormal(prior_mean)
        @test typeof(prior_dist) <: Distribution
    end

    @testset "Check distribution properties" begin
        prior_mean = 2.0
        prior_dist = HalfNormal(prior_mean)
        #Check Distributions.jl mean function
        @test mean(prior_dist) ≈ prior_mean
        samples = rand(prior_dist, 10_000)
        #Check mean from direct sampling of folded distribution and ANOVA and Variance F test comparisons
        direct_samples = randn(10_000) * prior_mean * sqrt(pi) / sqrt(2) .|> abs
        mean_pval = OneWayANOVATest(samples, direct_samples) |> pvalue
        @test mean_pval > 1e-6 #Very unlikely to fail if the model is correctly implemented
        var_pval = VarianceFTest(samples, direct_samples) |> pvalue
        @test var_pval > 1e-6 #Very unlikely to fail if the model is correctly implemented
    end
end
