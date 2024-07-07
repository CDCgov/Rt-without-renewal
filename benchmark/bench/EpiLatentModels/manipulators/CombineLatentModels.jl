let
    using Distributions, Turing
    s = Intercept(Normal(0, 1))
    ns = AR()
    con = CombineLatentModels([s, ns])
    mdl = generate_latent(con, 10)
    suite["CombineLatentModels"] = make_turing_suite(mdl; check = true)
end
