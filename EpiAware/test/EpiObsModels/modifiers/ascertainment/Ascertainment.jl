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
    @test_throws DimensionMismatch asc.transform([1.0, 2.0], [0.1, 0.2, 0.3])
    @test asc.latent_prefix == "Ascertainment"

    custom_transform(Y_t, x) = Y_t .* exp.(x)
    asc_custom = Ascertainment(NegativeBinomialError(), FixedIntercept(0.1);
        transform = custom_transform, latent_prefix = "A")
    @test asc_custom.model == NegativeBinomialError()
    @test asc_custom.latent_model == PrefixLatentModel(FixedIntercept(0.1), "A")
    @test asc_custom.transform == custom_transform
    @test asc_custom.latent_prefix == "A"
end

@testitem "Test all Ascertainment constructor variants" begin
    using Turing, LogExpFunctions

    # Test full constructor
    custom_transform(Y_t, x) = Y_t .* exp.(x)
    asc1 = Ascertainment(
        NegativeBinomialError(), FixedIntercept(0.1), custom_transform, "Custom")
    @test asc1.model == NegativeBinomialError()
    @test asc1.latent_model isa PrefixLatentModel
    @test asc1.transform == custom_transform
    @test asc1.latent_prefix == "Custom"

    # Test constructor with default transform and prefix
    asc2 = Ascertainment(NegativeBinomialError(), FixedIntercept(0.1))
    @test asc2.model == NegativeBinomialError()
    @test asc2.latent_model isa PrefixLatentModel
    @test asc2.transform([1.0, 2.0], [0.1, 0.2]) ≈
          LogExpFunctions.xexpy.([1.0, 2.0], [0.1, 0.2])
    @test asc2.latent_prefix == "Ascertainment"

    # Test constructor with custom transform
    asc3 = Ascertainment(
        NegativeBinomialError(), FixedIntercept(0.1), transform = custom_transform)
    @test asc3.transform == custom_transform
    @test asc3.latent_prefix == "Ascertainment"

    # Test constructor with custom prefix
    asc4 = Ascertainment(
        NegativeBinomialError(), FixedIntercept(0.1), latent_prefix = "Test")
    @test asc4.latent_prefix == "Test"

    # Test keyword argument constructor
    asc5 = Ascertainment(
        model = NegativeBinomialError(),
        latent_model = FixedIntercept(0.1),
        transform = custom_transform,
        latent_prefix = "Keyword"
    )
    @test asc5.model == NegativeBinomialError()
    @test asc5.latent_model isa PrefixLatentModel
    @test asc5.transform == custom_transform
    @test asc5.latent_prefix == "Keyword"

    # Test empty latent_prefix (should not use PrefixLatentModel)
    asc6 = Ascertainment(NegativeBinomialError(), FixedIntercept(0.1), latent_prefix = "")
    @test asc6.latent_model isa FixedIntercept
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
