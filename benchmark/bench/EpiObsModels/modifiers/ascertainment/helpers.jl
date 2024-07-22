let
    obs = ascertainment_dayofweek(PoissonError())
    incidence_each_ts = 100.0
    nweeks = 2
    I_t = fill(incidence_each_ts, nweeks * 7)
    obs_model = generate_observations(obs, I_t, I_t)
    suite["ascertainment_dayofweek"] = make_epiaware_suite(obs_model)
end
