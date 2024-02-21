
@testitem "direct infections with RW latent process" begin
    using Distributions, Turing, DynamicPPL
    # Define test inputs
    y_t = missing # Data will be generated from the model
    data = EpiData([0.2, 0.3, 0.5], [0.1, 0.4, 0.5], 0.8, 10, exp)
    process_priors = merge(default_rw_priors(), default_delay_obs_priors())
    pos_shift = 1e-6


    epimodel = DirectInfections(data)
    rwp = EpiAware.random_walk_process()
    # Call the function
    test_mdl = make_epi_inference_model(
        y_t,
        epimodel,
        rwp,
        delay_observations;
        process_priors,
        pos_shift,
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
    process_priors = merge(default_rw_priors(), default_delay_obs_priors())
    pos_shift = 1e-6

    epimodel = ExpGrowthRate(data)
    rwp = EpiAware.random_walk_process()

    # Call the function
    test_mdl = make_epi_inference_model(
        y_t,
        epimodel,
        rwp,
        delay_observations;
        process_priors,
        pos_shift,
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
    process_priors = merge(default_rw_priors(), default_delay_obs_priors())
    pos_shift = 1e-6

    epimodel = Renewal(data)
    rwp = EpiAware.random_walk_process()

    # Call the function
    test_mdl = make_epi_inference_model(
        y_t,
        epimodel,
        rwp,
        delay_observations;
        process_priors,
        pos_shift,
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
