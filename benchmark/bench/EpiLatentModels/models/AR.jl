let
    latent = AR()
    mdl = generate_latent(latent, 10)
    suite["AR"] = make_turing_suite(mdl; check = true)
end
