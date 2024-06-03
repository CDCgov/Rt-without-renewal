@testitem "StackObservationModels constructor" begin
    obs = StackObservationModels(
        [PoissonError(), NegativeBinomialError()], ["Poisson", "NegativeBinomial"])

    @test obs.models == [PoissonError(), NegativeBinomialError()]
    @test obs.model_names == ["Poisson", "NegativeBinomial"]

    obs_type = StackObservationModels([PoissonError(), NegativeBinomialError()])

    @test obs_type.models == [PoissonError(), NegativeBinomialError()]
    @test obs_type.model_names == ["PoissonError", "NegativeBinomialError"]

    obs_named = StackObservationModels((
        Cases = PoissonError(), Deaths = NegativeBinomialError()))

    @test obs_named.models == [PoissonError(), NegativeBinomialError()]
    @test obs_named.model_names == ["Cases", "Deaths"]
end

@testitem "StackObervationModels generate_observations works as expected" begin
    using Turing, DynamicPPL

    struct TestObs <: AbstractTuringObservationModel
        mean::Float64
        std::Float64
    end

    @model function EpiAwareBase.generate_observations(obs_model::TestObs, y_t, Y_t)
        if ismissing(y_t)
            y_t = Vector{Int}(undef, length(Y_t))
        end

        for i in eachindex(y_t)
            y_t[i] ~ Normal(obs_model.mean, obs_model.std)
        end
        return y_t, (; cluster_factor = obs_model.mean)
    end

    obs = StackObservationModels(
        [TestObs(10, 2), TestObs(20, 1)], ["cases", "deaths"]
    )

    y_t = missing
    Y_t = fill(10, 10)

    gen_obs = generate_observations(obs, y_t, Y_t)

    samples = sample(gen_obs, Prior(), 100; progress = false)
    gen = mapreduce(vcat, generated_quantities(gen_obs, samples))
    @test all(gen .== 10.0)
end
