let
    I_t = fill(10, 100)
    delay_obs = LatentDelay(NegativeBinomialError(), [0.1, 0.2, 0.3, 0.4])
    mdl = generate_observations(delay_obs, I_t, I_t)
    suite["LatentDelay"] = make_turing_suite(mdl; check = true)
end
