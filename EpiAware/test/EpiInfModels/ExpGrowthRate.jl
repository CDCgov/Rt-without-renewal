@testitem "generate_latent_infs dispatched on ExpGrowthRate" begin
    using Distributions, Turing, HypothesisTests, DynamicPPL
    gen_int = [0.2, 0.3, 0.5]
    transformation = exp

    data = EpiData(gen_int, transformation)
    log_init_incidence_prior = Normal()
    rt_model = ExpGrowthRate(data, log_init_incidence_prior)

    #Example incidence data
    recent_incidence = [10.0, 20.0, 30.0]
    log_init = log(5.0)
    rt = [log(recent_incidence[1]) - log_init; diff(log.(recent_incidence))]

    #Check log_init is sampled from the correct distribution
    sample_init_inc = sample(
        generate_latent_infs(rt_model, rt), Prior(), 1000; progress = false) |>
                      chn -> chn[:init_incidence] |>
                             Array |>
                             vec

    ks_test_pval = ExactOneSampleKSTest(sample_init_inc, log_init_incidence_prior) |> pvalue
    @test ks_test_pval > 1e-6 #Very unlikely to fail if the model is correctly implemented

    #Check that the generated incidence is correct given correct initialisation
    mdl_incidence = generated_quantities(generate_latent_infs(rt_model, rt),
        (init_incidence = log_init,))
    @test mdl_incidence ≈ recent_incidence
end
