@testitem "Testing SafeNegativeBinomial Constructor " begin
    μ = 10.0
    α = 0.05
    # calculate the r, p parameters
    σ² = μ + α * μ^2
    p = μ / σ²
    r = μ * p / (1 - p)

    dist = SafeNegativeBinomial(r, p)
    @test typeof(dist) <: SafeNegativeBinomial
end

@testitem "Check distribution properties of SafeNegativeBinomial" begin
    using Distributions, HypothesisTests, StatsBase
    μ = 10.0
    α = 0.05
    # calculate the r, p parameters
    σ² = μ + α * μ^2
    p = μ / σ²
    r = μ * p / (1 - p)

    dist = SafeNegativeBinomial(r, p)
    #Check Distributions.jl mean function
    @test mean(dist) ≈ μ
    @test var(dist) ≈ σ²
    n = 100_000
    samples = [rand(dist) for _ in 1:n]
    #Check mean from direct sampling of Distributions version and ANOVA and Variance F test comparisons
    _dist = NegativeBinomial(r, p)
    direct_samples = rand(_dist, n)
    mean_pval = OneWayANOVATest(samples, direct_samples) |> pvalue
    @test mean_pval > 1e-6 #Very unlikely to fail if the model is correctly implemented
    var_pval = VarianceFTest(samples, direct_samples) |> pvalue
    @test var_pval > 1e-6 #Very unlikely to fail if the model is correctly implemented
    # Check that the variance is closer than 6 std of estimator to the direct samples
    # very unlikely failure if the model is correctly implemented
    @test abs(var(dist) - var(direct_samples)) < 6 * var(_dist)^2 * sqrt(2 / n)
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
    μ = exp(48.0) #Large value of λ
    α = 0.05
    # calculate the r, p parameters
    σ² = μ + α * μ^2
    p = μ / σ²
    r = μ * p / (1 - p)

    dist = SafeNegativeBinomial(r, p)
    @testset "Large value of mean samples a BigInt with SafePoisson" begin
        @test rand(dist) isa Real
    end
    @testset "Large value of mean sample failure with Poisson" begin
        _dist = EpiAware.EpiAwareUtils._negbin(dist)
        @test_throws InexactError rand(_dist)
    end
end

@testitem "Check gradients can be evaluated for logpdf of SafeNegativeBinomial" begin
    using Distributions, ReverseDiff, FiniteDifferences, ForwardDiff
    μ = exp(48.0) #Large value of λ
    α = 0.05
    # calculate the r, p parameters
    σ² = μ + α * μ^2
    p = μ / σ²
    r = μ * p / (1 - p)

    # Make a helper function for grad calls
    f(x) = SafeNegativeBinomial(exp(x[1]), p) |> nb -> logpdf(nb, 100)
    g_fin_diff = grad(central_fdm(5, 1), f, [log(r)])[1]

    # Compiled ReverseDiff version
    input = randn(1)
    const f_tape = ReverseDiff.GradientTape(f, input)
    const compiled_f_tape = ReverseDiff.compile(f_tape)
    cfg = ReverseDiff.GradientConfig(input)
    g_rvd = ReverseDiff.gradient(f, [log(r)], cfg)

    # ForwardDiff version
    g_fd = ForwardDiff.gradient(f, [log(r)])

    @test g_fin_diff ≈ g_rvd
    @test g_fin_diff ≈ g_fd
end
