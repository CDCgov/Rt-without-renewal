@testset "define_forecast_epiprob" begin
    using EpiAwarePipeline
    pipeline = SmoothOutbreakPipeline()

    inference_configs = make_inference_configs(pipeline)

    case_data = missing
    tspan = (1, 28)
    epimethod = make_inference_method(pipeline)

    epiprob = InferenceConfig(rand(inference_configs); case_data, tspan, epimethod) |>
              define_epiprob

    @test_throws AssertionError define_forecast_epiprob(epiprob, -1)

    n_fr = 7
    forecast_epiprob = define_forecast_epiprob(epiprob, 7)
    @test forecast_epiprob.tspan == (epiprob.tspan[1], epiprob.tspan[2] + n_fr)
end
