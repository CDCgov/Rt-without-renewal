let
    latent = HierarchicalNormal()
    mdl = generate_latent(latent, 10)
    suite["HierarchicalNormal"] = make_epiaware_suite(mdl)
end
