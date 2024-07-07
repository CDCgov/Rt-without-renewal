let
    prefix_mdl = PrefixLatentModel(model = HierarchicalNormal(), prefix = "Test")
    mdl = generate_latent(prefix_mdl, 10)
    suite["PrefixLatentModel"] = make_turing_suite(mdl; check = true)
end
