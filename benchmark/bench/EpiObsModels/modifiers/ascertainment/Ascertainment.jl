let
    obs = Ascertainment(NegativeBinomialError(), FixedIntercept(0.1); link = x -> x)
    gen_obs = generate_observations(obs, missing, fill(100, 10))
    suite["Ascertainment"] = make_turing_suite(gen_obs; check = true)
end
