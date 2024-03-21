@testitem "Testing scan function with addition" begin
    # Test case 1: Testing with addition function
    function add(a, b)
        return a + b, a + b
    end

    xs = [1, 2, 3, 4, 5]
    expected_ys = [1, 3, 6, 10, 15]
    expected_carry = 15

    # Check that a generic function CAN'T be used
    @test_throws MethodError scan(add, 0, xs)

    # Check that a callable subtype of `AbstractEpiModel` CAN be used
    struct TestEpiModelAdd <: AbstractEpiModel
    end
    function (epi_model::TestEpiModelAdd)(a, b)
        return a + b, a + b
    end

    ys, carry = scan(TestEpiModelAdd(), 0, xs)

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

    # Check that a generic function CAN'T be used
    @test_throws MethodError ys, carry=scan(multiply, 1, xs)

    # Check that a callable subtype of `AbstractEpiModel` CAN be used
    struct TestEpiModelMult <: AbstractEpiModel
    end

    function (epi_model::TestEpiModelMult)(a, b)
        return a * b, a * b
    end

    ys, carry = scan(TestEpiModelMult(), 1, xs)

    @test ys == expected_ys
    @test carry == expected_carry
end
