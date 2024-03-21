@testitem "Testing create_discrete_pmf function" begin
    using Distributions
    # Test case 1: Testing with a non-negative distribution
    @testset "Test case 1" begin
        dist = Normal()
        @test_throws AssertionError create_discrete_pmf(dist, Δd = 1.0, D = 3.0)
    end

    # Test case 2: Testing with Δd = 0.0
    @testset "Test case 2" begin
        dist = Exponential(1.0)
        @test_throws AssertionError create_discrete_pmf(dist, Δd = 0.0, D = 3.0)
    end

    @testset "Test case 3" begin
        dist = Exponential(1.0)
        @test_throws AssertionError create_discrete_pmf(dist, Δd = 3.0, D = 1.0)
    end

    # Test case 4: Testing output against expected PMF basic version - single
    # interval censoring with left hand approx.
    @testset "Test case 4" begin
        dist = Exponential(1.0)
        expected_pmf = [(exp(-(t - 1)) - exp(-t)) / (1 - exp(-5)) for t in 1:5]
        pmf = create_discrete_pmf(dist,
            Val(:single_censored);
            primary_approximation_point = 0.0,
            Δd = 1.0,
            D = 5.0)
        @test pmf≈expected_pmf atol=1e-15
    end

    # Test case 5: Testing output against expected PMF basic version - double
    # interval censoring
    @testset "Test case 5" begin
        dist = Exponential(1.0)
        expected_pmf_uncond = [exp(-1)
                               [(1 - exp(-1)) * (exp(1) - 1) * exp(-s) for s in 1:9]]
        expected_pmf = expected_pmf_uncond ./ sum(expected_pmf_uncond)
        pmf = create_discrete_pmf(dist; Δd = 1.0, D = 10.0)
        @test expected_pmf≈pmf atol=1e-15
    end

    @testset "Test case 6" begin
        dist = Exponential(1.0)
        @test_throws AssertionError create_discrete_pmf(dist, Δd = 1.0, D = 3.5)
    end
end
