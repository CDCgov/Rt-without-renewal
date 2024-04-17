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
    broadcasted_model = generate_latent(model, 10)
    rand_model = rand(broadcasted_model)

    @test length(rand_model.ϵ_t) == 2
    fix_model = fix(broadcasted_model, (σ_RW = 1, rw_init = 1))
    sample_model = sample(fix_model, Prior(), 100; progress = false)
    gen_model = sample_model |>
                chn -> mapreduce(hcat, generated_quantities(fix_model, chn)) do gen
        gen[1]
    end

    @testset "Testing gen_model matrix" begin
        for col in eachcol(gen_model)
            unique_values = unique(col)
            @test length(unique_values) == 2

            @test count(x -> x == unique_values[1], col) == 5
            @test count(x -> x == unique_values[2], col) == 5
        end
    end
end
