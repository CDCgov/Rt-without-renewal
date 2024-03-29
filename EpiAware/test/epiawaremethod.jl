@testitem "EpiMethod" begin
    @testset "Constructor" begin
        struct TestNUTSMethod <: AbstractNUTSMethod
        end

        pre_sampler_steps = [ManyPathfinder(), ManyPathfinder()]
        sampler = TestNUTSMethod()
        method = EpiMethod(pre_sampler_steps, sampler)
        @test method.pre_sampler_steps == pre_sampler_steps
        @test method.sampler == sampler
    end
end
