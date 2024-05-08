@testitem "FixedIntercept constructor works as expected" begin
    using Distributions: Normal
    int = FixedIntercept(0.1)
    @test typeof(int) <: AbstractTuringLatentModel
    @test int.intercept == 0.1
end

@testitem "FixedIntercept generate_latent method works as expected" begin
    using Turing
    int = FixedIntercept(0.1)
    int_model = generate_latent(int, 10)
    int_model_out = int_model()
    @test length(int_model_out[1]) == 10
    @test all(x -> x == int_model_out[2].intercept, int_model_out[1])
end
