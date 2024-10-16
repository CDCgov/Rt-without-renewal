let
    model = IDD(Normal(0, 1))
    mdl = generate_latent(model, 10)
    suite["IDD"] = make_epiaware_suite(mdl)
end
