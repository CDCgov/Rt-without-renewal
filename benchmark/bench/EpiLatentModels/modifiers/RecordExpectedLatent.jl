begin
    mdl = RecordExpectedLatent(HierarchicalNormal())
    latent = generate_latent(mdl, 2)
    suite["RecordExpectedLatent"] = make_epiaware_suite(latent)
end
