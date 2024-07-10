suite["integration"] = BenchmarkGroup()

let
    using Distributions

    obs = LatentDelay(
        Ascertainment(
            NegativeBinomialError(), Intercept(Normal(0, 1)); link = x -> exp.(x)
        ),
        LogNormal(1.6, 0.2)
    )
    I_t = fill(100, 10)
    gen_obs = generate_observations(obs, I_t, I_t)
    suite["Integration"]["LatentDelay - Ascertainment"] = make_turing_suite(
        gen_obs; check = true)
end

let
    I_t = fill(10, 100)
    delay_obs = LatentDelay(
        LatentDelay(
            NegativeBinomialError(),
            [0.1, 0.2, 0.3, 0.4]
        ),
        LogNormal(1.4, 0.2)
    )
    mdl = generate_observations(delay_obs, I_t, I_t)
    suite["LatentDelay-LatentDelay"] = make_turing_suite(mdl; check = true)
end

let
    obs = StackObservationModels(
        [
            Ascertainment(
                NegativeBinomialError(),
                Intercept(Normal(0.5, 0.1))
            ),
            LatentDelay(
                PoissonError(),
                [0.1, 0.2, 0.3, 0.4]
            )
        ],
        ["cases", "deaths"]
    )

    Y_t = fill(10, 10)
    y_t = (cases = Y_t, deaths = Y_t)

    gen_obs = generate_observations(obs, y_t, Y_t)

    suite["StackObservationModels-LatentDelay-Ascertainment"] = make_turing_suite(
        gen_obs; check = true)
end
