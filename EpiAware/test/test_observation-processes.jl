@testitem "Testing delay obs against theoretical properties" begin
    using DynamicPPL, Turing, Distributions
    using HypothesisTests#: ExactOneSampleKSTest, pvalue

    # Set up test data with fixed infection
    I_t = [10.0, 20.0, 30.0]

    # Replace with your own implementation of AbstractEpiModel
    # Delay kernel is just event observed on same day
    data = EpiData([0.2, 0.3, 0.5], [1.0], 0.8, 3, exp)
    epimodel = DirectInfections(data)

    # Set up priors
    priors = default_delay_obs_priors()
    neg_bin_cf = 0.05

    # Call the function
    mdl = EpiAware.delay_observations(
        missing,
        I_t,
        epimodel;
        pos_shift = 1e-6,
        priors...
    )
    fix_mdl = fix(mdl, neg_bin_cluster_factor = neg_bin_cf) # Effectively Poisson sampling

    n_samples = 2000
    first_obs = sample(fix_mdl, Prior(), n_samples) |>
                chn -> generated_quantities(fix_mdl, chn) .|>
                       (gen -> gen[1][1]) |>
                       vec
    direct_samples = EpiAware.mean_cc_neg_bin(I_t[1], neg_bin_cf) |>
                     dist -> rand(dist, n_samples)

    #For discrete distributions, checking mean and variance is as expected
    #Check mean
    mean_pval = OneWayANOVATest(first_obs, direct_samples) |> pvalue
    @test mean_pval > 1e-6 #Very unlikely to fail if the model is correctly implemented

    #Check var
    var_pval = VarianceFTest(first_obs, direct_samples) |> pvalue
    @test var_pval > 1e-6 #Very unlikely to fail if the model is correctly implemented
end
