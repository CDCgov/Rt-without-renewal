@testitem "BroadcastLatentModel constructor" begin
    model = RandomWalk()
    @testset "Testing BroadcastLatentModel properties" begin
        broadcast_model = BroadcastLatentModel(model, 7, RepeatEach())
        @test typeof(broadcast_model) <: BroadcastLatentModel
        @test typeof(broadcast_model.model) <: RandomWalk
        @test broadcast_model.period == 7
        @test broadcast_model.broadcast_rule == RepeatEach()
    end

    @testset "Testing BroadcastLatentModel properties with default values" begin
        broadcast_model = BroadcastLatentModel(
            model, period = 7, broadcast_rule = RepeatEach())
        @test typeof(broadcast_model) <: BroadcastLatentModel
        @test typeof(broadcast_model.model) <: RandomWalk
        @test broadcast_model.period == 7
        @test broadcast_model.model == model
        @test broadcast_model.broadcast_rule == RepeatEach()
    end
end

@testitem "generate_latent function with BroadcastLatentModel" begin
    using Turing, DynamicPPL
    model = BroadcastLatentModel(RandomWalk(), 5, RepeatBlock())
    broadcasted_model = generate_latent(model, 15)
    rand_model = rand(broadcasted_model)

    @test length(rand_model.ϵ_t) == 2
    fix_model = fix(
        broadcasted_model,
        (std = 2.0, rw_init = 1.0, ϵ_t = [1, 2])
    )
    out = fix_model()
    @test out == vcat(fill(1.0, 5), fill(3.0, 5), fill(7.0, 5))
end
