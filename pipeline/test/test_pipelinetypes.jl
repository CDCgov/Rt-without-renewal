@testset "EpiAwarePipeline Tests" begin
    using .AnalysisPipeline
    @testset "AbstractEpiAwarePipeline" begin
        @test_throws MethodError AbstractEpiAwarePipeline()
    end

    @testset "EpiAwarePipeline" begin
        @test isa(EpiAwarePipeline(), EpiAwarePipeline)
        @test EpiAwarePipeline <: AbstractEpiAwarePipeline
    end

    @testset "RtwithoutRenewalPipeline" begin
        @test isa(RtwithoutRenewalPipeline(), RtwithoutRenewalPipeline)
        @test RtwithoutRenewalPipeline <: AbstractEpiAwarePipeline
    end
end
