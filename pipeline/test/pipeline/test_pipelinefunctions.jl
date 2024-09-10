@testset "do_truthdata tests" begin
    using EpiAwarePipeline, Dagger
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
    using EpiAwarePipeline, Dagger, EpiAware

    pipetype = SmoothOutbreakPipeline
    pipeline = pipetype(; ndraws = 40, testmode = true)
    truthdata_dg_task = do_truthdata(pipeline)
    truthdatas = fetch.(truthdata_dg_task)
    inference_configs = make_inference_configs(pipeline)
    inference_method = make_inference_method(pipeline)
    truthdata = truthdatas[1]
    inference_config = inference_configs[1]

    tspan = make_tspan(
        pipeline; T = inference_config["T"], lookback = inference_config["lookback"])

    config = InferenceConfig(
        inference_config; case_data = truthdata["y_t"], truth_I_t = truthdata["I_t"],
        truth_I0 = truthdata["truth_I0"], tspan, epimethod = inference_method)

    map(inference_configs) do inference_config
        generate_inference_results(
            truthdatas[1], inference_config, pipeline; inference_method)
    end

    inference_results_tsk = make_inference(pipeline)
    inference_results = fetch.(inference_results_tsk)

    for pipetype in [SmoothOutbreakPipeline, MeasuresOutbreakPipeline,
        SmoothEndemicPipeline, RoughEndemicPipeline]
        pipeline = pipetype(; ndraws = 40, testmode = true)
        inference_results_tsk = make_inference(pipeline)
        inference_results = fetch.(inference_results_tsk)
        @test length(inference_results) == 1
        @test all([result["inference_results"] isa EpiAwareObservables
                   for result in inference_results])
    end
end

@testset "do_pipeline test: just run" begin
    using EpiAwarePipeline
    pipeline = EpiAwareExamplePipeline()
    res = do_pipeline(pipeline)
    fetch(res)
    @test isnothing(res)
end

@testset "do_pipeline test: just run as a vector" begin
    using EpiAwarePipeline
    pipelines = fill(EpiAwareExamplePipeline(), 2)
    res = do_pipeline(pipelines)
    fetch(res)
    @test isnothing(res)
end
