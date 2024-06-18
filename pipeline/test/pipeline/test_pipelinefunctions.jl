@testset "do_truthdata tests" begin
    using EpiAwarePipeline, Dagger
    pipeline = EpiAwareExamplePipeline()
    truthdata_dg_task = do_truthdata(pipeline)
    truthdata = fetch.(truthdata_dg_task)

    @test length(truthdata) == 1
    @test all([data["y_t"] isa Vector{Union{Missing, Real}} for data in truthdata])
end

@testset "do_inference tests" begin
    using EpiAwarePipeline
    pipeline = EpiAwareExamplePipeline()

    function make_inference()
        truthdata = do_truthdata(pipeline)
        do_inference(truthdata[1:1], pipeline)
    end

    inference_results_tsk = make_inference()
    inference_results = fetch.(inference_results_tsk)
    @test length(inference_results) == 1
    @test all([result["inference_results"] isa EpiAwareObservables for result in inference_results])
end

@testset "do_pipeline test: just run" begin
    using EpiAwarePipeline
    pipeline = EpiAwareExamplePipeline()
    res = do_pipeline(pipeline)
    @test isnothing(res)
end
