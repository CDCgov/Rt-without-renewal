@testitem "Testing generate_observation_kernel function defaults" begin
    using SparseArrays
    delay_int = [0.2, 0.5, 0.3]
    time_horizon = 5
    expected_K = SparseMatrixCSC([0.2 0 0 0 0
                                  0.5 0.2 0 0 0
                                  0.3 0.5 0.2 0 0
                                  0 0.3 0.5 0.2 0
                                  0 0 0.3 0.5 0.2])
    K = EpiAware.EpiObsModels.generate_observation_kernel(delay_int, time_horizon)
    @test K == expected_K
end

@testitem "Test generate_observation_kernel partial=false setting" begin
    using SparseArrays
    delay_int = [0.2, 0.5, 0.3]
    time_horizon = 5
    expected_K = SparseMatrixCSC([0.2 0.5 0.3 0 0
                                  0 0.2 0.5 0.3 0
                                  0 0 0.2 0.5 0.3])
    K = EpiAware.EpiObsModels.generate_observation_kernel(
        delay_int, time_horizon; partial = false)
    @test K == expected_K
end
