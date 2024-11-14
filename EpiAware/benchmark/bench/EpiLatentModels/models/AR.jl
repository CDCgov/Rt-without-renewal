let
    latent = AR()
    mdl = generate_latent(latent, 10)
    suite["AR"] = make_epiaware_suite(mdl)
end
