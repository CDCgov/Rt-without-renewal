@testitem "Testing broadcast_n default" begin
    struct TestBroadcastModel <: EpiAware.EpiAwareBase.AbstractBroadcastRule
    end

    @test isnothing(broadcast_n(TestBroadcastModel(), missing, missing, missing))
end

@testitem "Testing broadcast_rule default" begin
    struct TestBroadcastModel <: EpiAware.EpiAwareBase.AbstractBroadcastRule
    end

    @test isnothing(broadcast_rule(TestBroadcastModel(), missing, missing))
end
