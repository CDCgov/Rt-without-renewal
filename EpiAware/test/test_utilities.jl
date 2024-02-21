@testitem "Testing scan function with addition" begin
    # Test case 1: Testing with addition function
    function add(a, b)
        return a + b, a + b
    end

    xs = [1, 2, 3, 4, 5]
    expected_ys = [1, 3, 6, 10, 15]
    expected_carry = 15
    ys, carry = EpiAware.scan(add, 0, xs)
    @test ys == expected_ys
    @test carry == expected_carry
end

@testitem "Testing scan function with multiplication" begin
    # Test case 2: Testing with multiplication function
    function multiply(a, b)
        return a * b, a * b
    end

    xs = [1, 2, 3, 4, 5]
    expected_ys = [1, 2, 6, 24, 120]
    expected_carry = 120

    ys, carry = EpiAware.scan(multiply, 1, xs)
    @test ys == expected_ys
    @test carry == expected_carry
end

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
        expected_pmf = [(exp(-(t - 1)) - exp(-t)) / (1 - exp(-5)) for t = 1:5]
        pmf = create_discrete_pmf(
            dist,
            Val(:single_censored);
            primary_approximation_point = 0.0,
            Δd = 1.0,
            D = 5.0,
        )
        @test pmf ≈ expected_pmf atol = 1e-15
    end

    # Test case 5: Testing output against expected PMF basic version - double
    # interval censoring
    @testset "Test case 5" begin
        dist = Exponential(1.0)
        expected_pmf_uncond = [
            exp(-1)
            [(1 - exp(-1)) * (exp(1) - 1) * exp(-s) for s = 1:9]
        ]
        expected_pmf = expected_pmf_uncond ./ sum(expected_pmf_uncond)
        pmf = create_discrete_pmf(dist; Δd = 1.0, D = 10.0)
        @test expected_pmf ≈ pmf atol = 1e-15
    end

    @testset "Test case 6" begin
        dist = Exponential(1.0)
        @test_throws AssertionError create_discrete_pmf(dist, Δd = 1.0, D = 3.5)
    end

end

@testitem "Testing r_to_R function" begin
    #Test that zero exp growth rate imples R0 = 1
    @testset "Test case 1" begin
        r = 0
        w = ones(5) |> x -> x ./ sum(x)
        expected_ratio = 1
        ratio = EpiAware.r_to_R(r, w)
        @test ratio ≈ expected_ratio atol = 1e-15
    end

    #Test MethodError when w is not a vector
    @testset "Test case 2" begin
        r = 0
        w = 1
        @test_throws MethodError EpiAware.r_to_R(r, w)
    end

end

@testitem "Testing generate_observation_kernel function" begin
    using SparseArrays
    @testset "Test case 1" begin
        delay_int = [0.2, 0.5, 0.3]
        time_horizon = 5
        expected_K = SparseMatrixCSC(
            [
                0.2 0 0 0 0
                0.5 0.2 0 0 0
                0.3 0.5 0.2 0 0
                0 0.3 0.5 0.2 0
                0 0 0.3 0.5 0.2
            ],
        )
        K = EpiAware.generate_observation_kernel(delay_int, time_horizon)
        @test K == expected_K
    end

end

@testitem "Testing neg_MGF function" begin
    # Test case 1: Testing with positive r and non-empty weight vector
    @testset "Test case 1" begin
        r = 0.5
        w = [0.2, 0.3, 0.5]
        expected_result = 0.2 * exp(-0.5 * 1) + 0.3 * exp(-0.5 * 2) + 0.5 * exp(-0.5 * 3)
        result = EpiAware.neg_MGF(r, w)
        @test result ≈ expected_result atol = 1e-15
    end

    # Test case 2: Testing with zero r and non-empty weight vector
    @testset "Test case 2" begin
        r = 0
        w = [0.1, 0.2, 0.3, 0.4]
        expected_result =
            0.1 * exp(-0 * 1) + 0.2 * exp(-0 * 2) + 0.3 * exp(-0 * 3) + 0.4 * exp(-0 * 4)
        result = EpiAware.neg_MGF(r, w)
        @test result ≈ expected_result atol = 1e-15
    end

end

@testitem "Testing dneg_MGF_dr function" begin

    # Test case 1: Testing with positive r and non-empty weight vector
    @testset "Test case 1" begin
        r = 0.5
        w = [0.2, 0.3, 0.5]
        expected_result =
            -(0.2 * 1 * exp(-0.5 * 1) + 0.3 * 2 * exp(-0.5 * 2) + 0.5 * 3 * exp(-0.5 * 3))
        result = EpiAware.dneg_MGF_dr(r, w)
        @test result ≈ expected_result atol = 1e-15
    end

    # Test case 2: Testing with zero r and non-empty weight vector
    @testset "Test case 2" begin
        r = 0
        w = [0.1, 0.2, 0.3, 0.4]
        expected_result = -(
            0.1 * 1 * exp(-0 * 1) +
            0.2 * 2 * exp(-0 * 2) +
            0.3 * 3 * exp(-0 * 3) +
            0.4 * 4 * exp(-0 * 4)
        )
        result = EpiAware.dneg_MGF_dr(r, w)
        @test result ≈ expected_result atol = 1e-15
    end

end
@testitem "Testing spread_draws function" begin
    using DataFramesMeta, Turing

    # Test case 1: Testing with non-empty Chains object
    @testset "Test case 1" begin
        X = rand(100, 2, 3)
        chn = Chains(X, [:a, :b])
        expected_df = DataFrame()
        expected_df[!, ".draw"] = 1:300
        expected_df[!, ".iteration"] = repeat(1:100, 3)
        expected_df[!, ".chain"] = vcat(fill(1, 100), fill(2, 100), fill(3, 100))
        expected_df.a = X[:, 1, :] |> vec
        expected_df.b = X[:, 2, :] |> vec

        df = spread_draws(chn)
        @test df == expected_df
    end
end
