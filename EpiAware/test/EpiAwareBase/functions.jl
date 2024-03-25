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

@testitem "_apply_method function: default" begin
    using Turing
    struct TestEpiMethod <: EpiAware.EpiAwareBase.AbstractEpiMethod
    end

    @model test_mdl() = begin
        x ~ Normal(0, 1)
    end

    mdl = test_mdl()

    @test isnothing(_apply_method(TestEpiMethod(), mdl, nothing))
end
