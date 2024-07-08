let
    latent = HierarchicalNormal()
    mdl = generate_latent(latent, 10)
    suite["HierarchicalNormal"] = make_turing_suite(mdl; check = true)
end
