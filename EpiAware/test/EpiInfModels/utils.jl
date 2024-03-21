
@testitem "Testing r_to_R function" begin
    #Test that zero exp growth rate imples R0 = 1
    @testset "Test case 1" begin
        r = 0
        w = ones(5) |> x -> x ./ sum(x)
        expected_ratio = 1
        ratio = EpiAware.r_to_R(r, w)
        @test ratio≈expected_ratio atol=1e-15
    end

    #Test MethodError when w is not a vector
    @testset "Test case 2" begin
        r = 0
        w = 1
        @test_throws MethodError EpiAware.r_to_R(r, w)
    end
end

@testitem "Testing neg_MGF function" begin
    # Test case 1: Testing with positive r and non-empty weight vector
    @testset "Test case 1" begin
        r = 0.5
        w = [0.2, 0.3, 0.5]
        expected_result = 0.2 * exp(-0.5 * 1) + 0.3 * exp(-0.5 * 2) + 0.5 * exp(-0.5 * 3)
        result = EpiAware.EpiInfModels.neg_MGF(r, w)
        @test result≈expected_result atol=1e-15
    end

    # Test case 2: Testing with zero r and non-empty weight vector
    @testset "Test case 2" begin
        r = 0
        w = [0.1, 0.2, 0.3, 0.4]
        expected_result = 0.1 * exp(-0 * 1) + 0.2 * exp(-0 * 2) + 0.3 * exp(-0 * 3) +
                          0.4 * exp(-0 * 4)
        result = EpiAware.EpiInfModels.neg_MGF(r, w)
        @test result≈expected_result atol=1e-15
    end
end

@testitem "Testing dneg_MGF_dr function" begin

    # Test case 1: Testing with positive r and non-empty weight vector
    @testset "Test case 1" begin
        r = 0.5
        w = [0.2, 0.3, 0.5]
        expected_result = -(0.2 * 1 * exp(-0.5 * 1) + 0.3 * 2 * exp(-0.5 * 2) +
                            0.5 * 3 * exp(-0.5 * 3))
        result = EpiAware.EpiInfModels.dneg_MGF_dr(r, w)
        @test result≈expected_result atol=1e-15
    end

    # Test case 2: Testing with zero r and non-empty weight vector
    @testset "Test case 2" begin
        r = 0
        w = [0.1, 0.2, 0.3, 0.4]
        expected_result = -(0.1 * 1 * exp(-0 * 1) +
                            0.2 * 2 * exp(-0 * 2) +
                            0.3 * 3 * exp(-0 * 3) +
                            0.4 * 4 * exp(-0 * 4))
        result = EpiAware.EpiInfModels.dneg_MGF_dr(r, w)
        @test result≈expected_result atol=1e-15
    end
end
