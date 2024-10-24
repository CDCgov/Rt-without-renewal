@testitem "Test TransformObservationModel constructor" begin
    using Turing, LogExpFunctions

    # Test default constructor
    trans_obs = TransformObservationModel(NegativeBinomialError())
    @test trans_obs.model == NegativeBinomialError()
    @test trans_obs.transform([1.0, 2.0, 3.0]) == log1pexp.([1.0, 2.0, 3.0])

    # Test constructor with custom transform
    custom_transform = x -> exp.(x)
    trans_obs_custom = TransformObservationModel(NegativeBinomialError(), custom_transform)
    @test trans_obs_custom.model == NegativeBinomialError()
    @test trans_obs_custom.transform([1.0, 2.0, 3.0]) == exp.([1.0, 2.0, 3.0])

    # Test kwarg constructor
    trans_obs_kwarg = TransformObservationModel(
        model = PoissonError(), transform = custom_transform)
    @test trans_obs_kwarg.model == PoissonError()
    @test trans_obs_kwarg.transform == custom_transform
end

@testitem "Test TransformObservationModel generate_observations" begin
    using Turing, LogExpFunctions, Distributions

    # Test with default log1pexp transform
    trans_obs = TransformObservationModel(NegativeBinomialError())
    gen_obs = generate_observations(trans_obs, missing, fill(10.0, 1))
    samples = sample(gen_obs, Prior(), 1000; progress = false)["y_t[1]"]

    # Reverse the transform
    reversed_samples = samples .|> exp |> x -> x .- 1 .|> log
    # Apply the transform again
    recovered_samples = log1pexp.(reversed_samples)

    @test all(isapprox.(samples, recovered_samples, rtol = 1e-6))

    # Test with custom transform and Poisson distribution
    custom_transform = x -> x .^ 2  # Square transform
    trans_obs_custom = TransformObservationModel(PoissonError(), custom_transform)
    gen_obs_custom = generate_observations(trans_obs_custom, missing, fill(5.0, 1))
    samples_custom = sample(gen_obs_custom, Prior(), 1000; progress = false)
    # Reverse the transform
    reversed_samples_custom = sqrt.(samples_custom["y_t[1]"])
    # Apply the transform again
    recovered_samples_custom = custom_transform.(reversed_samples_custom)

    @test all(isapprox.(samples_custom["y_t[1]"], recovered_samples_custom, rtol = 1e-6))
end
