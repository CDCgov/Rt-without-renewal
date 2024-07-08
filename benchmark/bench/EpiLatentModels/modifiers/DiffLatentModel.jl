let
    using Distributions
    n = 10
    d = 2
    rw_model = RandomWalk()
    init_priors = [Normal(0.0, 1.0), Normal(1.0, 2.0)]
    diff_model = DiffLatentModel(model = rw_model, init_priors = init_priors)

    latent_model = generate_latent(diff_model, n)
    suite["DiffLatentModel"] = make_turing_suite(latent_model; check = true)
end
