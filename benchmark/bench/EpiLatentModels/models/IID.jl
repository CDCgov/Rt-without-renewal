let
    using Distributions
    model = IID(Normal(0, 1))
    mdl = generate_latent(model, 10)
    suite["IID"] = make_epiaware_suite(mdl)
end
