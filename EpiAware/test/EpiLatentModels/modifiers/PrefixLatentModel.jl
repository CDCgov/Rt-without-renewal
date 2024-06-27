@testitem "Test PrefixLatentModel constructor" begin
    model = PrefixLatentModel(model = HierarchicalNormal(), prefix = "Test")

    @test typeof(model.model) <: HierarchicalNormal
    @test model.prefix == "Test"
end

@testitem "Test generate_latent dispatches to prefix_submodel as expected" begin
    model = PrefixLatentModel(model = HierarchicalNormal(), prefix = "Test")
    mdl = generate_latent(model, 10)
    draw = rand(mdl)
    @test typeof(draw[:var"Test.ϵ_t"]) <: AbstractVector
end
