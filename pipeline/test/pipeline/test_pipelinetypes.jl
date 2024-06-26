@testset "EpiAwarePipeline Tests" begin
    using EpiAwarePipeline
    @testset "AbstractEpiAwarePipeline" begin
        @test_throws MethodError AbstractEpiAwarePipeline()
    end
    @testset "RtwithoutRenewalPipeline" begin
        @test isa(RtwithoutRenewalPipeline(), RtwithoutRenewalPipeline)
        @test RtwithoutRenewalPipeline <: AbstractEpiAwarePipeline
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
