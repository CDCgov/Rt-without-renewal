let
    latent = RandomWalk()
    mdl = generate_latent(latent, 10)
    suite["RandomWalk"] = make_epiaware_suite(mdl)
end
