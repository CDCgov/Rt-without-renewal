@testitem "Null Model Tests" begin
    # Test that Null can be instantiated
    @test Null() isa Null

    # Test that generate_latent returns nothing
    null = Null()
    @test isnothing(generate_latent(null, 10)())
end
