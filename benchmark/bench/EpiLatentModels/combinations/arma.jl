let
    model = arma()
    mdl = generate_latent(model, 10)
    suite["arma"] = make_epiaware_suite(mdl)
end
