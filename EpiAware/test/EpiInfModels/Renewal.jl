@testitem "Renewal function: internal generate infs" begin
    using LinearAlgebra, Distributions
    gen_int = [0.2, 0.3, 0.5]
    delay_int = [0.1, 0.4, 0.5]
    cluster_coeff = 0.8
    time_horizon = 10
    transformation = exp

    data = EpiData(gen_int, transformation)
    epi_model = Renewal(data; initialisation_prior = Normal())

    function generate_infs(recent_incidence, Rt)
        new_incidence = Rt * dot(recent_incidence, epi_model.data.gen_int)
        [new_incidence; recent_incidence[1:(epi_model.data.len_gen_int - 1)]], new_incidence
    end

    recent_incidence = [10, 20, 30]
    Rt = 1.5

    expected_new_incidence = Rt * dot(recent_incidence, [0.2, 0.3, 0.5])
    expected_output = [expected_new_incidence; recent_incidence[1:2]],
    expected_new_incidence

    @test generate_infs(recent_incidence, Rt) == expected_output
end

@testitem "Renewal with a population size step function: internal generate infs" begin
    using LinearAlgebra, Distributions
    gen_int = [0.2, 0.3, 0.5]
    delay_int = [0.1, 0.4, 0.5]
    cluster_coeff = 0.8
    time_horizon = 10
    transformation = exp
    pop_size = 1000.0

    data = EpiData(gen_int, transformation)
    recurrent_step = EpiInfModels.ConstantRenewalWithPopulationStep(
        reverse(gen_int), pop_size)
    epi_model = Renewal(data, Normal(), recurrent_step)

    function generate_infs(recent_incidence_and_available_sus, Rt)
        recent_incidence, S = recent_incidence_and_available_sus
        new_incidence = max(S / epi_model.recurrent_step.pop_size, 1e-6) * Rt *
                        dot(recent_incidence, epi_model.data.gen_int)
        new_S = S - new_incidence
        new_recent_incidence_and_available_sus = (
            [new_incidence; recent_incidence[1:(epi_model.data.len_gen_int - 1)]], new_S)

        return (new_recent_incidence_and_available_sus, new_incidence)
    end

    recent_incidence = [10, 20, 30]
    Rt = 1.5

    expected_new_incidence = Rt * dot(recent_incidence, [0.2, 0.3, 0.5])
    expected_new_recent_incidence_and_available_sus = (
        [expected_new_incidence; recent_incidence[1:2]], pop_size - expected_new_incidence)
    expected_output = (
        expected_new_recent_incidence_and_available_sus, expected_new_incidence)

    @test generate_infs((recent_incidence, pop_size), Rt) == expected_output
end

@testitem "generate_latent_infs dispatched on Renewal" begin
    using Distributions, Turing, HypothesisTests, DynamicPPL, LinearAlgebra
    gen_int = [0.2, 0.3, 0.5]
    transformation = exp

    data = EpiData(gen_int, transformation)
    log_init_incidence_prior = Normal()

    renewal_model = Renewal(data; initialisation_prior = log_init_incidence_prior)

    #Actual Rt
    Rt = [1.0, 1.2, 1.5, 1.5, 1.5]
    log_Rt = log.(Rt)
    initial_incidence = [1.0, 1.0, 1.0]#aligns with initial exp growth rate of 0.

    #Check log_init is sampled from the correct distribution
    @time sample_init_inc = sample(generate_latent_infs(renewal_model, log_Rt),
        Prior(), 1000; progress = false) |>
                            chn -> chn[:init_incidence] |>
                                   Array |>
                                   vec

    ks_test_pval = ExactOneSampleKSTest(sample_init_inc, log_init_incidence_prior) |> pvalue
    @test ks_test_pval > 1e-6 #Very unlikely to fail if the model is correctly implemented

    #Check that the generated incidence is correct given correct initialisation
    #Check first three days "by hand"
    mdl_incidence = generated_quantities(
        generate_latent_infs(renewal_model,
            log_Rt), (init_incidence = 0.0,))

    day1_incidence = dot(initial_incidence, gen_int) * Rt[1]
    day2_incidence = dot(initial_incidence, gen_int) * Rt[2]
    day3_incidence = dot([day2_incidence, 1.0, 1.0], gen_int) * Rt[3]

    @test mdl_incidence[1:3] ≈ [day1_incidence, day2_incidence, day3_incidence]
end

@testitem "generate_latent_infs dispatched on Renewal with a population size step function" begin
    using Distributions, Turing, HypothesisTests, DynamicPPL, LinearAlgebra
    gen_int = [0.2, 0.3, 0.5]
    transformation = exp
    pop_size = 1000.0

    data = EpiData(gen_int, transformation)
    log_init_incidence_prior = Normal()
    recurrent_step = EpiInfModels.ConstantRenewalWithPopulationStep(
        reverse(gen_int), pop_size)
    epi_model = Renewal(data, Normal(), recurrent_step)

    #Actual Rt
    Rt = [1.0, 1.2, 1.5, 1.5, 1.5]
    log_Rt = log.(Rt)
    initial_incidence = [1.0, 1.0, 1.0]#aligns with initial exp growth rate of 0.

    #Check log_init is sampled from the correct distribution
    @time sample_init_inc = sample(generate_latent_infs(epi_model, log_Rt),
        Prior(), 1000; progress = false) |>
                            chn -> chn[:init_incidence] |>
                                   Array |>
                                   vec

    ks_test_pval = ExactOneSampleKSTest(sample_init_inc, log_init_incidence_prior) |> pvalue
    @test ks_test_pval > 1e-6 #Very unlikely to fail if the model is correctly implemented

    #Check that the generated incidence is correct given correct initialisation
    #Check first three days "by hand"
    mdl_incidence = generated_quantities(
        generate_latent_infs(epi_model,
            log_Rt), (init_incidence = 0.0,))

    day1_incidence = dot(initial_incidence, gen_int) * Rt[1]
    day2_incidence = ((pop_size - day1_incidence) / pop_size) *
                     dot([day1_incidence; initial_incidence[1:2]], gen_int) * Rt[2]
    day3_incidence = ((pop_size - day1_incidence - day2_incidence) / pop_size) *
                     dot([day2_incidence; day1_incidence; initial_incidence[1]], gen_int) *
                     Rt[3]

    @test mdl_incidence[1:3] ≈ [day1_incidence, day2_incidence, day3_incidence]
end
