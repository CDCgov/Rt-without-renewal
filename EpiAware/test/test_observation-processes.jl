@testitem "Testing delay obs against theoretical properties" begin
    using DynamicPPL, Turing, Distributions
    using HypothesisTests#: ExactOneSampleKSTest, pvalue

    # Set up test data with fixed infection
    I_t = [10.0, 20.0, 30.0]
    obs_prior = EpiAware.default_delay_obs_priors()

    # Delay kernel is just event observed on same day
    delay_obs = EpiAware.DelayObservations([1.0], length(I_t),
        obs_prior[:neg_bin_cluster_factor_prior])

    # Set up priors
    neg_bin_cf = 0.05

    # Call the function
    mdl = EpiAware.generate_observations(delay_obs,
        missing,
        I_t;
        pos_shift = 1e-6)
    fix_mdl = fix(mdl, (neg_bin_cluster_factor = neg_bin_cf,))

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

@testitem "Testing DelayObservations struct" begin
    using Distributions

    # Test case 1
    delay_int = [0.2, 0.3, 0.5]
    time_horizon = 30
    obs_prior = EpiAware.default_delay_obs_priors()

    obs_model = EpiAware.DelayObservations(delay_int, time_horizon,
        obs_prior[:neg_bin_cluster_factor_prior])

    @test size(obs_model.delay_kernel) == (time_horizon, time_horizon)
    @test obs_model.neg_bin_cluster_factor_prior == obs_prior[:neg_bin_cluster_factor_prior]

    # Test case 2
    delay_distribution = Uniform(0.0, 20.0)
    time_horizon = 365
    neg_bin_cluster_factor_prior = 0.05
    D_delay = 10.0
    Δd = 1.0

    obs_model = EpiAware.DelayObservations(delay_distribution = delay_distribution,
        time_horizon = time_horizon,
        neg_bin_cluster_factor_prior = obs_prior[:neg_bin_cluster_factor_prior],
        D_delay = D_delay,
        Δd = Δd)

    @test size(obs_model.delay_kernel) == (time_horizon, time_horizon)
    @test obs_model.neg_bin_cluster_factor_prior == obs_prior[:neg_bin_cluster_factor_prior]
end

@testitem "Testing generate_observations default" begin
    struct TestObsModel <: EpiAware.AbstractObservationModel
    end

    @test try
        EpiAware.generate_observations(TestObsModel(), missing, missing; pos_shift = 1e-6)
        true
    catch
        false
    end
end
