@testitem "Test prefix_submodel can handle empty prefix" begin
    submodel = prefix_submodel(
        CombineLatentModels([FixedIntercept(0.1), AR()]), generate_latent, "", 10)
    draw = rand(submodel)
    @test typeof(draw[:var"Combine.2.ϵ_t"]) <: AbstractVector
end

@testitem "Test prefix_submodel can handle non-empty prefix" begin
    submodel = prefix_submodel(
        CombineLatentModels([FixedIntercept(0.1), AR()]), generate_latent, "Test", 10)
    draw = rand(submodel)
    @test typeof(draw[:var"Test.Combine.2.ϵ_t"]) <: AbstractVector
end
