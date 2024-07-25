let
    I_t = fill(10, 100)
    weekly_agg = Aggregate(PoissonError(), [0, 0, 0, 0, 7, 0, 0])
    mdl = generate_observations(weekly_agg, I_t, I_t)
    suite["Aggregate"] = make_epiaware_suite(mdl)
end
