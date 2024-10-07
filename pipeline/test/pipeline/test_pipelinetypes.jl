@testset "EpiAwarePipeline Tests" begin
    @testset "AbstractEpiAwarePipeline" begin
        @test_throws MethodError AbstractEpiAwarePipeline()
    end
    @testset "AbstractEpiAwarePipeline" begin
        @test_throws MethodError AbstractRtwithoutRenewalPipeline()
    end

    @testset "RtwithoutRenewalPipeline subtypes" begin
        concrete_scenario_pipes = [
            SmoothOutbreakPipeline(),
            MeasuresOutbreakPipeline(),
            SmoothEndemicPipeline(),
            RoughEndemicPipeline()
        ]
        map(concrete_scenario_pipes) do pipeline
            @test pipeline isa AbstractRtwithoutRenewalPipeline
        end
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
