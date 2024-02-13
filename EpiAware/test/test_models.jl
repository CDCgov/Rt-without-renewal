
@testitem "`log_infections` with RW latent process" begin
    using Distributions, Turing, DynamicPPL
    # Define test inputs
    y_t = missing # Data will be generated from the model
    epimodel = EpiModel([0.2, 0.3, 0.5], [0.1, 0.4, 0.5], 0.8, 10)
    latent_process_priors = EpiAware.STANDARD_RW_PRIORS
    transform_function = exp
    n_generate_ahead = 0
    pos_shift = 1e-6
    neg_bin_cluster_factor = 0.5
    neg_bin_cluster_factor_prior = Gamma(3, 0.05 / 3)

    # Call the function
    test_mdl = log_infections(
        y_t,
        epimodel,
        random_walk;
        latent_process_priors,
        transform_function,
        pos_shift,
        neg_bin_cluster_factor,
        neg_bin_cluster_factor_prior,
    )

    # Define expected outputs for a conditional model
    # Underlying log-infections are const value 1 for all time steps and
    # any other unfixed parameters

    fixed_test_mdl = fix(
        test_mdl,
        (init_rw_value = log(1.0), σ²_RW = 0.0, neg_bin_cluster_factor = 0.05),
    )
    X = rand(fixed_test_mdl)
    expected_I_t = [1.0 for _ = 1:epimodel.time_horizon]
    gen = generated_quantities(fixed_test_mdl, rand(fixed_test_mdl))

    # Perform tests
    @test gen.I_t ≈ expected_I_t
end
