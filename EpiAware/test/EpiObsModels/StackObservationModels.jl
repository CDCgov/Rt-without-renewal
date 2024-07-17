@testitem "StackObservationModels constructor" begin
    obs = StackObservationModels(
        [PoissonError(), NegativeBinomialError()], ["Poisson", "NegativeBinomial"])

    prefix_p = PrefixObservationModel(PoissonError(), "Poisson")
    prefix_n = PrefixObservationModel(NegativeBinomialError(), "NegativeBinomial")
    @test obs.models == [prefix_p, prefix_n]
    @test obs.model_names == ["Poisson", "NegativeBinomial"]

    obs_named = StackObservationModels((
        Cases = PoissonError(), Deaths = NegativeBinomialError()))

    prefix_p = PrefixObservationModel(PoissonError(), "Cases")
    prefix_n = PrefixObservationModel(NegativeBinomialError(), "Deaths")
    @test obs_named.models == [prefix_p, prefix_n]
    @test obs_named.model_names == ["Cases", "Deaths"]
end

@testitem "StackObervationModels generate_observations works as expected" begin
    using Turing, DynamicPPL, DataFrames

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
        return y_t
    end

    obs = StackObservationModels(
        [TestObs(10, 2), TestObs(20, 1)], ["cases", "deaths"]
    )

    y_t = (cases = missing, deaths = missing)
    Y_t = fill(10, 10)

    gen_obs = generate_observations(obs, y_t, Y_t)

    samples = sample(gen_obs, Prior(), 1000; progress = false)

    # extract samples for cases.y_t and deaths_y_t
    # from the chain of samples (not using generated_quantities)
    function extract_obs(samples, obs_name)
        obs = group(samples, obs_name) |>
              DataFrame |>
              x -> stack(x, Not(:iteration, :chain)) |>
                   x -> x[!, :value]
        return obs
    end

    cases_y_t = extract_obs(samples, "cases.y_t")

    @test isapprox(mean(cases_y_t), 10.0, atol = 0.1)
    @test isapprox(std(cases_y_t), 2.0, atol = 0.1)

    deaths_y_t = extract_obs(samples, "deaths.y_t")

    @test isapprox(mean(deaths_y_t), 20, atol = 0.1)
    @test isapprox(std(deaths_y_t), 1.0, atol = 0.1)
end
