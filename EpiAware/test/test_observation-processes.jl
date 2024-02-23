@testitem "Testing delay obs against theoretical properties" begin
    using DynamicPPL, Turing
    # Set up test data with fixed infection
    I_t = [10.0, 20.0, 30.0]

    # Replace with your own implementation of AbstractEpiModel
    # Delay kernel is just event observed on same day
    data = EpiData([0.2, 0.3, 0.5], [1.0], 0.8, 3, exp)
    epimodel = DirectInfections(data)
    # Set up priors
    priors = default_delay_obs_priors()

    # Call the function
    mdl = EpiAware.delay_observations(
        missing,
        I_t,
        epimodel;
        pos_shift = 1e-6,
        priors...
    )
    fix_mdl = fix(mdl, neg_bin_cluster_factor = 0.00001) # Effectively Poisson sampling

    n_samples = 1000
    mean_first_obs = sample(fix_mdl, Prior(), n_samples) |>
                     chn -> generated_quantities(fix_mdl, chn) .|> (gen -> gen[1][1]) |>
                            mean

    theoretical_std_of_empiral_mean = sqrt(I_t[1]) / sqrt(n_samples)
    @test mean(mean_first_obs) - I_t[1] < 5 * theoretical_std_of_empiral_mean &&
          mean(mean_first_obs) - I_t[1] > -5 * theoretical_std_of_empiral_mean
end
