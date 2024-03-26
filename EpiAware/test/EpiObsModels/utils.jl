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

@testitem "Check overflow safety of Negative Binomial sampling" begin
    using Distributions
    big_mu = 1e30
    alpha = 0.5
    big_alpha = 1e30

    ex_σ² = (alpha * big_mu^2)
    p = big_mu / (big_mu + ex_σ²)
    r = big_mu^2 / ex_σ²

    #Direct definition
    nb = NegativeBinomial(r, p)

    @test_throws InexactError rand(nb) #Throws error due to overflow

    #Safe versions
    @test rand(EpiAware.EpiObsModels.NegativeBinomialMeanClust(big_mu, alpha)) isa Int
    @test rand(EpiAware.EpiObsModels.NegativeBinomialMeanClust(big_mu, big_alpha)) isa Int
end
