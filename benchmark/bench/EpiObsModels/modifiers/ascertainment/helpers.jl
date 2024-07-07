let
    obs = ascertainment_dayofweek(PoissonError())
    incidence_each_ts = 100.0
    nweeks = 2
    obs_model = generate_observations(obs, missing, fill(incidence_each_ts, nweeks * 7))
    suite["ascertainment_dayofweek"] = make_turing_suite(obs_model; check = true)
end
