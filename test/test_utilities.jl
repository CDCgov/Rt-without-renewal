@testset "Testing scan function with addition" begin
    # Test case 1: Testing with addition function
    function add(a, b)
        return a + b, a + b
    end

    xs = [1, 2, 3, 4, 5]
    expected_ys = [1, 3, 6, 10, 15]
    expected_carry = 15
    ys, carry = scan(add, 0, xs)
    @test ys == expected_ys
    @test carry == expected_carry
end

@testset "Testing scan function with multiplication" begin
    # Test case 2: Testing with multiplication function
    function multiply(a, b)
        return a * b, a * b
    end

    xs = [1, 2, 3, 4, 5]
    expected_ys = [1, 2, 6, 24, 120]
    expected_carry = 120

    ys, carry = scan(multiply, 1, xs)
    @test ys == expected_ys
    @test carry == expected_carry
end

@testset "Testing create_discrete_pmf function" begin
    # Test case 1: Testing with a non-negative distribution
    # function test_create_discrete_pmf_1()
    #     dist = Normal()
    #     pmf = create_discrete_pmf(dist, Δd=1.0, D=3.0)
    #     @test pmf ≈ expected_pmf
    # end
    # @testset "Test case 1" begin
    #     @test_throws AssertionError test_create_discrete_pmf_1()
    # end

    # # Test case 2: Testing with a negative distribution
    # function test_create_discrete_pmf_2()
    #     dist = [-0.2, 0.3, 0.5]
    #     @test_throws AssertionError create_discrete_pmf(dist, Δd=1.0, D=3.0)
    # end
    # @testset "Test case 2" begin
    #     @test_throws AssertionError test_create_discrete_pmf_2()
    # end

    # # Test case 3: Testing with Δd = 0.0
    # function test_create_discrete_pmf_3()
    #     dist = [0.2, 0.3, 0.5]
    #     @test_throws AssertionError create_discrete_pmf(dist, Δd=0.0, D=3.0)
    # end
    # @testset "Test case 3" begin
    #     @test_throws AssertionError test_create_discrete_pmf_3()
    # end

    # # Test case 4: Testing with D <= Δd
    # function test_create_discrete_pmf_4()
    #     dist = [0.2, 0.3, 0.5]
    #     @test_throws AssertionError create_discrete_pmf(dist, Δd=3.0, D=2.0)
    # end
    # @testset "Test case 4" begin
    #     @test_throws AssertionError test_create_discrete_pmf_4()
    # end
end