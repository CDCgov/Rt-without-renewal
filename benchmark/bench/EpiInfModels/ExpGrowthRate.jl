let
    using Distributions
    gen_int = [0.2, 0.3, 0.5]
    transformation = exp

    data = EpiData(gen_int, transformation)
    log_init_incidence_prior = Normal()
    rt_model = ExpGrowthRate(data, log_init_incidence_prior)

    #Example incidence data
    recent_incidence = [10.0, 20.0, 30.0]
    log_init = log(5.0)
    rt = [log(recent_incidence[1]) - log_init; diff(log.(recent_incidence))]

    mdl = generate_latent_infs(rt_model, rt)
    suite["ExpGrowthRate"] = make_epiaware_suite(mdl)
end
