@testitem "generate_infectionsdispatched on DirectInfections" begin
    using Distributions, Turing, HypothesisTests, DynamicPPL
    gen_int = [0.2, 0.3, 0.5]
    transformation = exp

    data = EpiData(gen_int, transformation)
    log_init_incidence_prior = Normal()

    direct_inf_model = DirectInfections(data, log_init_incidence_prior)

    log_init_scale = log(1.0)
    log_incidence = [10, 20, 30] .|> log
    expected_incidence = exp.(log_init_scale .+ log_incidence)

    #Check log_init is sampled from the correct distribution
    sample_init_inc = sample(
        generate_infections(direct_inf_model, log_incidence),
        Prior(), 1000; progress = false) |>
                      chn -> chn[:init_incidence] |>
                             Array |>
                             vec

    ks_test_pval = ExactOneSampleKSTest(sample_init_inc, log_init_incidence_prior) |> pvalue
    @test ks_test_pval > 1e-6 #Very unlikely to fail if the model is correctly implemented

    #Check that the generated incidence is correct given correct initialisation
    mdl_incidence = generated_quantities(
        generate_infectionsirect_inf_model,
            log_incidence),
        (init_incidence = log_init_scale,))

    @test mdl_incidence ≈ expected_incidence
end
