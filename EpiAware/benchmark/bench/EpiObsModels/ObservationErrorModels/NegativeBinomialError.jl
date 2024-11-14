let
    μ = 10.0
    n = 10
    nb_obs_model = NegativeBinomialError()
    Y_t = fill(μ, n)
    model = generate_observations(nb_obs_model, Y_t, Y_t)
    suite["NegativeBinomialError"] = make_epiaware_suite(model)
end
