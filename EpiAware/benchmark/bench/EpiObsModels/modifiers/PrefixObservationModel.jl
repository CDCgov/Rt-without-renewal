let
    model = PrefixObservationModel(model = NegativeBinomialError(), prefix = "Test")
    mdl = generate_observations(model, 9, 10)
    suite["PrefixObservationModel"] = make_epiaware_suite(mdl)
end
