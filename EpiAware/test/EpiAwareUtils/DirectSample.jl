@testitem "DirectSample constructor" begin
    ds = DirectSample(10)
    @test ds.n_samples == 10

    ds = DirectSample(nothing)
    @test ds.n_samples == nothing
end

# Test apply_method function
@testitem "DirectSample apply_method function" begin
    using Turing, Distributions
    # Define a simple model for testing
    @model function test_model()
        x ~ Normal(0, 1)
    end
    model = test_model()
    ds = DirectSample(10)
    result = apply_method(model, ds; progress = false)
    @test typeof(result) <: MCMCChains.Chains

    ds = DirectSample(nothing)
    result = apply_method(model, ds)
    @test typeof(result) <: NamedTuple
end
