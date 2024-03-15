@testitem "Testing delay obs against theoretical properties" begin
    using DynamicPPL, Turing, Distributions
    using HypothesisTests

    # Set up test data with fixed infection
    I_t = [10.0, 20.0, 30.0]
    obs_prior = default_delay_obs_priors()

    # Delay kernel is just event observed on same day
    delay_obs = DelayObservations([1.0], length(I_t),
        obs_prior[:neg_bin_cluster_factor_prior];
        pos_shift = 1e-6)

    # Set up priors
    neg_bin_cf = 0.05

    # Call the function
    mdl = generate_observations(delay_obs,
        missing,
        I_t)
    fix_mdl = fix(mdl, (neg_bin_cluster_factor = neg_bin_cf,))

    n_samples = 1000
    first_obs = sample(fix_mdl, Prior(), n_samples, progress = false) |>
                chn -> generated_quantities(fix_mdl, chn) .|>
                       (gen -> gen[1][1]) |>
                       vec
    direct_samples = EpiAware.EpiObsModels.NegativeBinomialMeanClust(
        I_t[1], neg_bin_cf^2) |>
                     dist -> rand(dist, n_samples)

    #For discrete distributions, checking mean and variance is as expected
    #Check mean
    mean_pval = OneWayANOVATest(first_obs, direct_samples) |> pvalue
    @test mean_pval > 1e-6 #Very unlikely to fail if the model is correctly implemented

    #Check var
    var_pval = VarianceFTest(first_obs, direct_samples) |> pvalue
    @test var_pval > 1e-6 #Very unlikely to fail if the model is correctly implemented
end

@testitem "Testing y_t observation handling and mean estimation" begin
    using DynamicPPL, Turing, Distributions
    # Define scenarios for y_t: fully observed, partially observed, and fully unobserved
    y_t_fully_observed = [10, 20, 30]
    y_t_partially_observed = [10, missing, 30]
    y_t_fully_unobserved = [missing, missing, missing]

    # Simulated infection data, could be the same across tests for simplicity
    I_t = [10.0, 20.0, 30.0]  # Assuming a simple case where all infections are known

    # Define a common setup for your model that can be reused across different y_t scenarios
    obs_prior = default_delay_obs_priors()
    delay_obs = DelayObservations(
        [1.0], length(I_t), obs_prior[:neg_bin_cluster_factor_prior];
        pos_shift = 1e-6)
    neg_bin_cf = 0.05  # Set up priors
    # Expected point estimate calculation setup

    # Test each y_t scenario
    for (scenario_name, y_t_scenario) in [("fully observed", y_t_fully_observed),
        ("partially observed", y_t_partially_observed),
        ("fully unobserved", y_t_fully_unobserved)]
        @testset "$scenario_name y_t" begin
            mdl = generate_observations(
                delay_obs, y_t_scenario, I_t)
            sampled_obs = sample(mdl, Prior(), 1000, progress = false) |>
                          chn -> generated_quantities(mdl, chn) .|>
                                 (gen -> gen[1]) |>
                                 collect

            # Calculate mean of generated quantities
            generated_means = Vector{Float64}(undef, length(sampled_obs[1, 1]))
            for i in 1:length(sampled_obs[1, 1])
                # Extracting and flattening all observations for the i-th I_t value across all samples
                observations_for_I_t = [sampled_obs[row, col][i]
                                        for row in 1:size(sampled_obs, 1),
                col in 1:size(sampled_obs, 2)]

                # Calculating the mean of these observations
                generated_means[i] = mean(observations_for_I_t)
            end
            # Calculate the absolute differences between generated means and I_t values
            abs_diffs = abs.(generated_means - I_t)

            # Perform the
            for i in eachindex(abs_diffs)
                @test abs_diffs[i] < 1
            end
        end
    end
end

@testitem "Testing DelayObservations struct" begin
    using Distributions

    # Test case 1
    delay_int = [0.2, 0.3, 0.5]
    time_horizon = 30
    obs_prior = default_delay_obs_priors()

    obs_model = DelayObservations(delay_int, time_horizon,
        obs_prior[:neg_bin_cluster_factor_prior])

    @test size(obs_model.delay_kernel) == (time_horizon, time_horizon)
    @test obs_model.neg_bin_cluster_factor_prior == obs_prior[:neg_bin_cluster_factor_prior]

    # Test case 2
    delay_distribution = Uniform(0.0, 20.0)
    time_horizon = 365
    D_delay = 10.0
    Δd = 1.0

    obs_model = DelayObservations(delay_distribution = delay_distribution,
        time_horizon = time_horizon,
        neg_bin_cluster_factor_prior = obs_prior[:neg_bin_cluster_factor_prior],
        D_delay = D_delay,
        Δd = Δd)

    @test size(obs_model.delay_kernel) == (time_horizon, time_horizon)
    @test obs_model.neg_bin_cluster_factor_prior == obs_prior[:neg_bin_cluster_factor_prior]
end

@testitem "Testing generate_observations default" begin
    struct TestObsModel <: EpiAware.EpiAwareBase.AbstractObservationModel
    end

    @test try
        generate_observations(TestObsModel(), missing, missing; pos_shift = 1e-6)
        true
    catch
        false
    end
end
