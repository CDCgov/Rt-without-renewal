@testitem "dayofweek constructor" begin
    model = RandomWalk()
    broadcast_model = dayofweek(model)
    @test typeof(broadcast_model) <: BroadcastLatentModel
    @test typeof(broadcast_model.model) <: RandomWalk
    @test broadcast_model.period == 7
    @test broadcast_model.broadcast_rule == RepeatEach()
end

@testitem "weekly constructor" begin
    model = AR()
    broadcast_model = weekly(model)
    @test typeof(broadcast_model) <: BroadcastLatentModel
    @test typeof(broadcast_model.model) <: AR
    @test broadcast_model.period == 7
    @test broadcast_model.broadcast_rule == RepeatBlock()
end
