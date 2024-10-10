@testitem "Test PrefixObservationModel constructor" begin
    model = PrefixObservationModel(model = PoissonError(), prefix = "Test")

    @test typeof(model.model) <: PoissonError
    @test model.prefix == "Test"
end

@testitem "Test generate_observations dispatches to prefix_submodel as expected" begin
    model = PrefixObservationModel(model = PoissonError(), prefix = "Test")

    mdl = generate_observations(model, missing, 10)
    draw = rand(mdl)
    @test typeof(draw[:var"Test.y_t[1]"]) <: Real
end
