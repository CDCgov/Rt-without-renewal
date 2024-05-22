@testset "test define_epiprob" begin
    using EpiAwarePipeline
    pipeline = RtwithoutRenewalPipeline()

    inference_configs = make_inference_configs(pipeline)

    case_data = missing
    tspan = (1, 28)
    epimethod = make_inference_method(pipeline)

    epiprob = InferenceConfig(rand(inference_configs); case_data, tspan, epimethod) |>
              define_epiprob

    @test epiprob isa EpiProblem
end
