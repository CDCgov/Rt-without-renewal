let
    model = IID()
    mdl = generate_latent(model, 10)
    suite["IID"] = make_epiaware_suite(mdl)
end
