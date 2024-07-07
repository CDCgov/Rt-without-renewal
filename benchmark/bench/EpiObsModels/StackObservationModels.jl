let
    obs = StackObservationModels(
        [NegativeBinomialError(), PoissonError()], ["cases", "deaths"]
    )

    Y_t = fill(10, 10)
    y_t = (cases = Y_t, deaths = Y_t)

    gen_obs = generate_observations(obs, y_t, Y_t)

    suite["StackObservationModels"] = make_turing_suite(gen_obs; check = true)
end
