begin
    mdl = RecordExpectedObs(NegativeBinomialError())
    gen_obs = generate_observations(mdl, fill(90, 5), fill(100, 5))
    suite["RecordExpectedObs"] = make_epiaware_suite(gen_obs)
end
