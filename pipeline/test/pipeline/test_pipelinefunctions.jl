@testset "do_truthdata tests" begin
    using Dagger
    for pipetype in [SmoothOutbreakPipeline, MeasuresOutbreakPipeline,
        SmoothEndemicPipeline, RoughEndemicPipeline]
        pipeline = pipetype(; testmode = true)
        truthdata_dg_task = do_truthdata(pipeline)
        truthdata = fetch.(truthdata_dg_task)

        @test length(truthdata) == 1
        @test all([data["y_t"] isa Vector{Union{Missing, T}} where {T <: Integer}
                   for data in truthdata])
    end
end

@testset "do_inference tests" begin
    using Dagger

    function make_inference(pipeline)
        truthdata_dg_task = do_truthdata(pipeline)
        truthdata = fetch.(truthdata_dg_task)
        do_inference(truthdata[1], pipeline)
    end

    for pipetype in [SmoothOutbreakPipeline, MeasuresOutbreakPipeline,
        SmoothEndemicPipeline, RoughEndemicPipeline]
        pipeline = pipetype(; ndraws = 20, nchains = 1, testmode = true)
        inference_results_tsk = make_inference(pipeline)
        inference_results = fetch.(inference_results_tsk)
        @test length(inference_results) == 1
        @test all([result["inference_results"] isa EpiAwareObservables
                   for result in inference_results])
    end
end

@testset "do_pipeline test: just run all pipeline objects" begin
    using Dagger
    pipelines = map([SmoothOutbreakPipeline, MeasuresOutbreakPipeline,
        SmoothEndemicPipeline, RoughEndemicPipeline]) do pipetype
        pipetype(; ndraws = 10, nchains = 1, testmode = true)
    end

    res = do_pipeline(pipelines)
    fetch(res)
    @test isnothing(res)
end
