@testset "define_forecast_epiprob" begin
    pipeline = SmoothOutbreakPipeline()

    inference_configs = make_inference_configs(pipeline)

    case_data = missing
    I_t = [1.0]
    I0 = 1.0
    tspan = (1, 28)
    epimethod = make_inference_method(pipeline)

    epiprob = InferenceConfig(
        rand(inference_configs), pipeline; case_data, truth_I_t = I_t,
        truth_I0 = I0, tspan, epimethod) |>
              define_epiprob

    @test_throws AssertionError define_forecast_epiprob(epiprob, -1)

    n_fr = 7
    forecast_epiprob = define_forecast_epiprob(epiprob, 7)
    @test forecast_epiprob.tspan == (epiprob.tspan[1], epiprob.tspan[2] + n_fr)
end
