let
    model = PrefixObservationModel(model = NegativeBinomialError(), prefix = "Test")
    mdl = generate_observations(model, 9, 10)
    suite["PrefixObservationModel"] = make_turing_suite(mdl; check = true)
end
