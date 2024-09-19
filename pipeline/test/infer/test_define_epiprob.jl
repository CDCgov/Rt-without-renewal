@testset "test define_epiprob" begin
    pipeline = SmoothOutbreakPipeline()

    inference_configs = make_inference_configs(pipeline)

    case_data = missing
    I_t = [1.0]
    I0 = 1.0
    tspan = (1, 28)
    epimethod = make_inference_method(pipeline)

    epiprob = InferenceConfig(rand(inference_configs); case_data, tspan,
        epimethod, truth_I_t = I_t, truth_I0 = I0) |>
              define_epiprob

    @test epiprob isa EpiProblem
end
