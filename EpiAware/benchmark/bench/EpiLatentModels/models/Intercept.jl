let
    using Distributions
    latent = Intercept(Normal(0, 1))
    mdl = generate_latent(latent, 10)
    suite["Intercept"] = make_epiaware_suite(mdl)
end
