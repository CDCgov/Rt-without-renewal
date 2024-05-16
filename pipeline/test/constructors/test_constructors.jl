@testset "make_inference_configs for basic pipeline" begin
    using .AnalysisPipeline
    pipeline = RtwithoutRenewalPipeline()
    make_inference_configs(pipeline)
    @test eltype(make_inference_configs(pipeline)) <: Dict
end

@testset "make_tspan for basic pipeline" begin
    using .AnalysisPipeline
    pipeline = RtwithoutRenewalPipeline()

    @test make_tspan(pipeline) isa Tuple
end

@testset "make_inference_method for basic pipeline" begin
    using .AnalysisPipeline, EpiAware
    pipeline = RtwithoutRenewalPipeline()

    @test make_inference_method(pipeline) isa AbstractEpiMethod
end

@testset "make_latent_models_names for basic pipeline" begin
    using .AnalysisPipeline
    pipeline = RtwithoutRenewalPipeline()

    @test make_latent_models_names(pipeline) isa Dict
end
