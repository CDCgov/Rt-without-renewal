let
    latent = MA()
    mdl = generate_latent(latent, 10)
    suite["MA"] = make_epiaware_suite(mdl)
end
