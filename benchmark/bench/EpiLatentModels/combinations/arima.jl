let
    model = arima()
    mdl = generate_latent(model, 10)
    suite["arima"] = make_epiaware_suite(mdl)
end
