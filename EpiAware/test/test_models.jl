
@testitem "direct infections with RW latent process" begin
    using Distributions, Turing, DynamicPPL
    # Define test inputs
    y_t = missing # Data will be generated from the model
    data = EpiData([0.2, 0.3, 0.5], [0.1, 0.4, 0.5], 0.8, 10, exp)
    latent_process_priors = default_rw_priors()
    transform_function = exp
    n_generate_ahead = 0
    pos_shift = 1e-6
    neg_bin_cluster_factor = 0.5
    neg_bin_cluster_factor_prior = Gamma(3, 0.05 / 3)

    epimodel = DirectInfections(data)

    # Call the function
    test_mdl = make_epi_inference_model(
        y_t,
        epimodel,
        random_walk;
        latent_process_priors,
        pos_shift,
        neg_bin_cluster_factor,
        neg_bin_cluster_factor_prior,
    )

    # Define expected outputs for a conditional model
    # Underlying log-infections are const value 1 for all time steps and
    # any other unfixed parameters

    fixed_test_mdl =
        fix(test_mdl, (init = log(1.0), σ²_RW = 0.0, neg_bin_cluster_factor = 0.05))
    X = rand(fixed_test_mdl)
    expected_I_t = [1.0 for _ = 1:epimodel.data.time_horizon]
    gen = generated_quantities(fixed_test_mdl, rand(fixed_test_mdl))

    # Perform tests
    @test gen.I_t ≈ expected_I_t
end

@testitem "exp growth with RW latent process" begin
    using Distributions, Turing, DynamicPPL
    # Define test inputs
    y_t = missing # Data will be generated from the model
    data = EpiData([0.2, 0.3, 0.5], [0.1, 0.4, 0.5], 0.8, 10, exp)
    latent_process_priors = default_rw_priors()
    transform_function = exp
    n_generate_ahead = 0
    pos_shift = 1e-6
    neg_bin_cluster_factor = 0.5
    neg_bin_cluster_factor_prior = Gamma(3, 0.05 / 3)

    epimodel = ExpGrowthRate(data)

    # Call the function
    test_mdl = make_epi_inference_model(
        y_t,
        epimodel,
        random_walk;
        latent_process_priors,
        pos_shift,
        neg_bin_cluster_factor,
        neg_bin_cluster_factor_prior,
    )

    # Define expected outputs for a conditional model
    # Underlying log-infections are const value 1 for all time steps and
    # any other unfixed parameters

    fixed_test_mdl =
        fix(test_mdl, (init = log(1.0), σ²_RW = 0.0, neg_bin_cluster_factor = 0.05))
    X = rand(fixed_test_mdl)
    expected_I_t = [1.0 for _ = 1:epimodel.data.time_horizon]
    gen = generated_quantities(fixed_test_mdl, rand(fixed_test_mdl))

    # # Perform tests
    @test gen.I_t ≈ expected_I_t
end

@testitem "Renewal with RW latent process" begin
    using Distributions, Turing, DynamicPPL
    # Define test inputs
    y_t = missing # Data will be generated from the model
    data = EpiData([0.2, 0.3, 0.5], [0.1, 0.4, 0.5], 0.8, 10, exp)
    latent_process_priors = default_rw_priors()
    transform_function = exp
    n_generate_ahead = 0
    pos_shift = 1e-6
    neg_bin_cluster_factor = 0.5
    neg_bin_cluster_factor_prior = Gamma(3, 0.05 / 3)

    epimodel = Renewal(data)

    # Call the function
    test_mdl = make_epi_inference_model(
        y_t,
        epimodel,
        random_walk;
        latent_process_priors,
        pos_shift,
        neg_bin_cluster_factor,
        neg_bin_cluster_factor_prior,
    )

    # Define expected outputs for a conditional model
    # Underlying log-infections are const value 1 for all time steps and
    # any other unfixed parameters

    fixed_test_mdl =
        fix(test_mdl, (init = log(1.0), σ²_RW = 0.0, neg_bin_cluster_factor = 0.05))
    X = rand(fixed_test_mdl)
    expected_I_t = [1.0 for _ = 1:epimodel.data.time_horizon]
    gen = generated_quantities(fixed_test_mdl, rand(fixed_test_mdl))

    # # Perform tests
    @test gen.I_t ≈ expected_I_t
end
