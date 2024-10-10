@testitem "Test Ascertainment constructor" begin
    using Turing, LogExpFunctions

    asc = Ascertainment(NegativeBinomialError(), FixedIntercept(0.1))
    @test asc.model == NegativeBinomialError()
    @test asc.latent_model == PrefixLatentModel(FixedIntercept(0.1), "Ascertainment")
    # Test transform function
    Y_t = [1.0, 2.0]
    x = [0.1, 0.2]
    expected_result = LogExpFunctions.xexpy.(Y_t, x)
    @test all(isapprox.(asc.transform(Y_t, x), expected_result, atol = 1e-6))
    @test asc.latent_prefix == "Ascertainment"

    custom_transform(Y_t, x) = Y_t .* exp.(x)
    asc_custom = Ascertainment(NegativeBinomialError(), FixedIntercept(0.1);
        transform = custom_transform, latent_prefix = "A")
    @test asc_custom.model == NegativeBinomialError()
    @test asc_custom.latent_model == PrefixLatentModel(FixedIntercept(0.1), "A")
    @test asc_custom.transform == custom_transform
    @test asc_custom.latent_prefix == "A"
end

@testitem "Test Ascertainment generate_observations" begin
    using Turing

    obs = Ascertainment(RecordExpectedObs(NegativeBinomialError()), FixedIntercept(0.1))
    gen_obs = generate_observations(obs, missing, fill(100.0, 10))
    samples = sample(gen_obs, Prior(), 100; progress = false)
    gen = get(samples, :exp_y_t).exp_y_t |>
          x -> vcat(x...)
    @test all(isapprox.(gen, 110.517, atol = 1e-3))

    # Test with custom transform
    custom_transform(Y_t, x) = Y_t .* (1 .+ x)
    obs_custom = Ascertainment(
        RecordExpectedObs(NegativeBinomialError()),
        FixedIntercept(0.1),
        transform = custom_transform
    )
    gen_obs_custom = generate_observations(obs_custom, missing, fill(100.0, 10))
    samples_custom = sample(gen_obs_custom, Prior(), 100; progress = false)
    gen_custom = get(samples_custom, :exp_y_t).exp_y_t |>
                 x -> vcat(x...)
    @test all(isapprox.(gen_custom, 110.0, atol = 1e-3))
end

@testitem "Test Ascertainment constructor with invalid transform" begin
    @test_throws ArgumentError Ascertainment(
        NegativeBinomialError(),
        FixedIntercept(0.1),
        transform = x -> exp.(x)
    )
end
