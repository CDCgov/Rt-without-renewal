
@testitem "EpiData constructor" begin
    gen_int = [0.2, 0.3, 0.5]
    transformation = exp

    data = EpiData(gen_int, transformation)

    @test length(data.gen_int) == 3
    @test data.len_gen_int == 3
    @test sum(data.gen_int) ≈ 1
    @test data.transformation(0.0) == 1.0
end

@testitem "EpiData constructor with distributions" begin
    using Distributions

    gen_distribution = Uniform(0.0, 10.0)
    cluster_coeff = 0.8
    time_horizon = 10
    D_gen = 10.0
    Δd = 1.0

    data = EpiData(gen_distribution;
        D_gen = 10.0)

    @test data.len_gen_int == Int64(D_gen / Δd) - 1

    @test sum(data.gen_int) ≈ 1
end

@testitem "Renewal function: internal generate infs" begin
    using LinearAlgebra, Distributions
    gen_int = [0.2, 0.3, 0.5]
    delay_int = [0.1, 0.4, 0.5]
    cluster_coeff = 0.8
    time_horizon = 10
    transformation = exp

    data = EpiData(gen_int, transformation)
    epimodel = Renewal(data, Normal())

    function generate_infs(recent_incidence, Rt)
        new_incidence = Rt * dot(recent_incidence, epimodel.data.gen_int)
        [new_incidence; recent_incidence[1:(epimodel.data.len_gen_int - 1)]], new_incidence
    end

    recent_incidence = [10, 20, 30]
    Rt = 1.5

    expected_new_incidence = Rt * dot(recent_incidence, [0.2, 0.3, 0.5])
    expected_output = [expected_new_incidence; recent_incidence[1:2]],
    expected_new_incidence

    @test generate_infs(recent_incidence, Rt) == expected_output
end

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
    sample_init_inc = sample(EpiAware.generate_latent_infs(rt_model, rt), Prior(), 1000) |>
                      chn -> chn[:init_incidence] |>
                             Array |>
                             vec

    ks_test_pval = ExactOneSampleKSTest(sample_init_inc, log_init_incidence_prior) |> pvalue
    @test ks_test_pval > 1e-6 #Very unlikely to fail if the model is correctly implemented

    #Check that the generated incidence is correct given correct initialisation
    mdl_incidence = generated_quantities(
        EpiAware.generate_latent_infs(rt_model, rt), (init_incidence = log_init,))
    @test mdl_incidence ≈ recent_incidence
end

@testitem "generate_latent_infs dispatched on DirectInfections" begin
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
        EpiAware.generate_latent_infs(direct_inf_model, log_incidence), Prior(), 1000) |>
                      chn -> chn[:init_incidence] |>
                             Array |>
                             vec

    ks_test_pval = ExactOneSampleKSTest(sample_init_inc, log_init_incidence_prior) |> pvalue
    @test ks_test_pval > 1e-6 #Very unlikely to fail if the model is correctly implemented

    #Check that the generated incidence is correct given correct initialisation
    mdl_incidence = generated_quantities(
        EpiAware.generate_latent_infs(direct_inf_model, log_incidence),
        (init_incidence = log_init_scale,))

    @test mdl_incidence ≈ expected_incidence
end
@testitem "generate_latent_infs function: default" begin
    latent_process = [0.1, 0.2, 0.3]
    init_incidence = 10.0

    struct TestEpiModel <: EpiAware.AbstractEpiModel
    end

    @test isnothing(EpiAware.generate_latent_infs(TestEpiModel(), latent_process))
end
@testitem "generate_latent_infs dispatched on Renewal" begin
    using Distributions, Turing, HypothesisTests, DynamicPPL, LinearAlgebra
    gen_int = [0.2, 0.3, 0.5]
    transformation = exp

    data = EpiData(gen_int, transformation)
    log_init_incidence_prior = Normal()

    renewal_model = Renewal(data, log_init_incidence_prior)

    #Actual Rt
    Rt = [1.0, 1.2, 1.5, 1.5, 1.5]
    log_Rt = log.(Rt)
    initial_incidence = [1.0, 1.0, 1.0]#aligns with initial exp growth rate of 0.

    #Check log_init is sampled from the correct distribution
    @time sample_init_inc = sample(
        EpiAware.generate_latent_infs(renewal_model, log_Rt), Prior(), 1000) |>
                            chn -> chn[:init_incidence] |>
                                   Array |>
                                   vec

    ks_test_pval = ExactOneSampleKSTest(sample_init_inc, log_init_incidence_prior) |> pvalue
    @test ks_test_pval > 1e-6 #Very unlikely to fail if the model is correctly implemented

    #Check that the generated incidence is correct given correct initialisation
    #Check first three days "by hand"
    mdl_incidence = generated_quantities(
        EpiAware.generate_latent_infs(renewal_model, log_Rt), (init_incidence = 0.0,))

    day1_incidence = dot(initial_incidence, gen_int) * Rt[1]
    day2_incidence = dot(initial_incidence, gen_int) * Rt[2]
    day3_incidence = dot([day2_incidence, 1.0, 1.0], gen_int) * Rt[3]

    @test mdl_incidence[1:3] ≈ [day1_incidence, day2_incidence, day3_incidence]
end
