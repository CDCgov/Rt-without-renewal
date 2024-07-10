let
    using Distributions
    obs = Ascertainment(NegativeBinomialError(), Intercept(Normal(0, 1)); link = x -> x)
    I_t = fill(100, 10)
    gen_obs = generate_observations(obs, I_t, I_t)
    suite["Ascertainment"] = make_turing_suite(gen_obs; check = true)
end
