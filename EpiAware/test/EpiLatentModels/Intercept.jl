@testitem "Intercept constructor works as expected" begin
    using Distributions: Normal
    int = Intercept(Normal(0, 1))
    @test int.intercept_prior == Normal(0, 1)
    @test typeof(int) == Intercept
end

@testitem "Intercept generate_latent method works as expected" begin
    using Distributions: Normal
    int = Intercept(Normal(0, 1))
    int_model = generate_latent(int, 10)
    @test length(int_model) == 10
    @test all(x -> x == int_model[1], int_model)
end
