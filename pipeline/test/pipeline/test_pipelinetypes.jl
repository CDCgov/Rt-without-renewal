@testset "EpiAwarePipeline Tests" begin
    using EpiAwarePipeline
    @testset "AbstractEpiAwarePipeline" begin
        @test_throws MethodError AbstractEpiAwarePipeline()
    end
    @testset "AbstractEpiAwarePipeline" begin
        @test_throws MethodError AbstractRtwithoutRenewalPipeline()
    end

    @testset "RtwithoutRenewalPipeline subtypes" begin
        @test SmoothOutbreakPipeline() isa AbstractRtwithoutRenewalPipeline
        @test MeasuresOutbreakPipeline() isa AbstractRtwithoutRenewalPipeline
    end
    @testset "RtwithoutRenewalPriorPipeline" begin
        @test isa(RtwithoutRenewalPriorPipeline(), RtwithoutRenewalPriorPipeline)
        @test RtwithoutRenewalPriorPipeline <: AbstractEpiAwarePipeline
    end
    @testset "EpiAwareExamplePipeline" begin
        @test isa(EpiAwareExamplePipeline(), EpiAwareExamplePipeline)
        @test EpiAwareExamplePipeline <: AbstractEpiAwarePipeline
    end
end
