@testitem "EpiMethod" begin
    @testset "Constructor" begin
        struct TestNUTSMethod <: AbstractEpiSamplingMethod
        end
        struct TestManyPathfinder <: AbstractEpiOptMethod
        end

        pre_sampler_steps = [TestManyPathfinder(), TestManyPathfinder()]
        sampler = TestNUTSMethod()
        method = EpiMethod(pre_sampler_steps, sampler)
        @test method.pre_sampler_steps == pre_sampler_steps
        @test method.sampler == sampler
    end
end
