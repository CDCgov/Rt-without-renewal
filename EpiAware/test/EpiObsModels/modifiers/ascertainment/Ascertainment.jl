@testitem "Test Ascertainment constructor" begin
    using Turing
    function natural(x)
        return x
    end

    asc = Ascertainment(NegativeBinomialError(), FixedIntercept(0.1); link = natural)
    @test asc.model == NegativeBinomialError()
    @test asc.latent_model == PrefixLatentModel(FixedIntercept(0.1), "Ascertainment")
    @test asc.link == natural
    @test asc.latent_prefix == "Ascertainment"

    asc_prefix = Ascertainment(NegativeBinomialError(), FixedIntercept(0.1);
        link = natural, latent_prefix = "A")
    @test asc_prefix.model == NegativeBinomialError()
    @test asc_prefix.latent_model == PrefixLatentModel(FixedIntercept(0.1), "A")
    @test asc_prefix.link == natural
    @test asc_prefix.latent_prefix == "A"
end

# make a test based on above example
@testitem "Test Ascertainment generate_observations" begin
    using Turing, DynamicPPL

    struct ExpectedObs <: AbstractTuringObservationModel
        model::AbstractTuringObservationModel
    end

    @model EpiAware.EpiAwareBase.generate_observations(model::ExpectedObs, y_t, Y_t) = begin
        expected_obs := Y_t
        @submodel y_t = generate_observations(model.model, y_t, Y_t)
    end

    obs = Ascertainment(
        ExpectedObs(NegativeBinomialError()), FixedIntercept(0.1); link = x -> x)
    gen_obs = generate_observations(obs, missing, fill(100, 10))
    samples = sample(gen_obs, Prior(), 100; progress = false)
    gen = get(samples, :expected_obs).expected_obs |>
          x -> vcat(x...)
    @test all(gen .== 10.0)
end
