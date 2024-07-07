let
    latent = RandomWalk()
    mdl = generate_latent(latent, 10)
    suite["RandomWalk"] = make_turing_suite(mdl; check = true)
end
