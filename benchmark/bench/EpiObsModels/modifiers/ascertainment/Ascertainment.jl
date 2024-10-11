let
    obs = Ascertainment(NegativeBinomialError(), FixedIntercept(0.1))
    I_t = fill(100, 10)
    gen_obs = generate_observations(obs, I_t, I_t)
    suite["Ascertainment"] = make_epiaware_suite(gen_obs)
end
