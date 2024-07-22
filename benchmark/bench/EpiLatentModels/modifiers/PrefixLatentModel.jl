let
    prefix_mdl = PrefixLatentModel(model = HierarchicalNormal(), prefix = "Test")
    mdl = generate_latent(prefix_mdl, 10)
    suite["PrefixLatentModel"] = make_epiaware_suite(mdl)
end
