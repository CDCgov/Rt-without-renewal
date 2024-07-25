@testset "simple_crps" begin
    # Test case 1: Forecasts equal to observation
    forecasts1 = [1.0, 1.0, 1.0, 1.0]
    observation1 = 1.0
    expected_crps1 = 0.0
    @test simple_crps(forecasts1, observation1) ≈ expected_crps1

    # Test case 2: Empty forecasts give an assertion error
    forecasts2 = []
    observation2 = 1.0
    expected_crps2 = 0.0
    @test_throws AssertionError simple_crps(forecasts2, observation2)
end
