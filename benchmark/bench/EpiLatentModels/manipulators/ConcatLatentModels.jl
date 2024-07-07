let
    using Distributions, Turing
    s = Intercept(Normal(0, 1))
    ns = RandomWalk()
    con = ConcatLatentModels([s, ns])
    mdl = generate_latent(con, 10)
    suite["ConcatLatentModels"] = make_turing_suite(mdl; check = false)
end
