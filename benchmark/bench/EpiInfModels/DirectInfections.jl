let
    using Distributions, OrdinaryDiffEq
    gen_int = [0.2, 0.3, 0.5]
    transformation = exp

    data = EpiData(gen_int, transformation)
    log_init_incidence_prior = Normal()

    direct_inf_model = DirectInfections(data, log_init_incidence_prior)

    log_init_scale = log(1.0)
    log_incidence = [10, 20, 30] .|> log
    expected_incidence = exp.(log_init_scale .+ log_incidence)

    mdl = generate_latent_infs(direct_inf_model, log_incidence)
    suite["DirectInfections"] = make_epiaware_suite(mdl)
end
