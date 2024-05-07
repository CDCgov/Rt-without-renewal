@testitem "TransformLatentModel constructor" begin
    using Distributions

    trans = TransformLatentModel(Intercept(Normal(2, 0.2)), x -> x .|> exp)
    @test typeof(trans) <: AbstractTuringLatentModel
    @test trans.model == Intercept(Normal(2, 0.2))
    @test trans.trans_function([1, 2, 3]) == [exp(1), exp(2), exp(3)]
end

@testitem "TransformLatentModel generate_latent method" begin
    using Turing, Distributions

    trans = TransformLatentModel(Intercept(Normal(2, 0.2)), x -> x .|> exp)
    trans_model = generate_latent(trans, 5)
    returns = trans_model()
    @test returns[1][1] == exp(returns[2].latent_aux.intercept)
end
