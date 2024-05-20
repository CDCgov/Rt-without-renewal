@testset "EpiAwarePipeline Tests" begin
    using AnalysisPipeline
    @testset "AbstractEpiAwarePipeline" begin
        @test_throws MethodError AbstractEpiAwarePipeline()
    end
    @testset "RtwithoutRenewalPipeline" begin
        @test isa(RtwithoutRenewalPipeline(), RtwithoutRenewalPipeline)
        @test RtwithoutRenewalPipeline <: AbstractEpiAwarePipeline
    end
end
