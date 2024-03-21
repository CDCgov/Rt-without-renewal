@testitem "Testing generate_observation_kernel function" begin
    using SparseArrays
    @testset "Test case 1" begin
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
end
