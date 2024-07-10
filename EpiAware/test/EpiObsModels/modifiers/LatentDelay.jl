@testitem "Testing LatentDelay struct" begin
    using Distributions

    # Define a dummy observation model for testing
    struct DummyObservationModel <: AbstractTuringObservationModel end
    dummy_model = DummyObservationModel()

    # Test case 1
    delay_int = [0.2, 0.3, 0.5]
    obs_model = LatentDelay(dummy_model, delay_int)

    @test obs_model.model == dummy_model
    @test obs_model.pmf == delay_int

    # Test case 2
    delay_distribution = Uniform(0.0, 20.0)
    D_delay = 10.0
    Δd = 1.0

    obs_model = LatentDelay(dummy_model, delay_distribution, D = D_delay, Δd = Δd)

    @test obs_model.model == dummy_model
    @test length(obs_model.pmf) == D_delay

    # Test case 3: check default right truncation
    delay_distribution = Gamma(3, 15 / 3)
    D_delay = nothing
    Δd = 1.0

    obs_model = LatentDelay(dummy_model, delay_distribution, D = D_delay, Δd = Δd)

    nn_perc_rounded = invlogcdf(delay_distribution, log(0.99)) |> x -> round(Int64, x)
    @test length(obs_model.pmf) == nn_perc_rounded
end

@testitem "Testing delay obs against theoretical properties" begin
    using DynamicPPL, Turing, Distributions
    using HypothesisTests

    # Set up test data with fixed infection
    I_t = [10.0, 20.0, 30.0]
    obs_model = NegativeBinomialError()

    # Delay kernel is just event observed on same day
    delay_obs = LatentDelay(NegativeBinomialError(), [1.0])

    # Set up priors
    neg_bin_cf = 0.05

    # Call the function
    mdl = generate_observations(delay_obs,
        missing,
        I_t)
    fix_mdl = fix(mdl, (cluster_factor = neg_bin_cf,))

    n_samples = 1000
    first_obs = sample(mdl, Prior(), n_samples; progress = false) |>
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
    delay_obs = LatentDelay(NegativeBinomialError(), [1.0])

    # Test each y_t scenario
    for (scenario_name, y_t_scenario) in [("fully observed", y_t_fully_observed),
        ("partially observed", y_t_partially_observed),
        ("fully unobserved", y_t_fully_unobserved)]
        @testset "$scenario_name y_t" begin
            mdl = generate_observations(delay_obs, y_t_scenario, I_t)
            sampled_obs = sample(mdl, Prior(), 1000; progress = false) |>
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

@testitem "Test LatenDelay generate_observations function" begin
    using DynamicPPL
    struct TestObs <: AbstractTuringObservationModel end

    @model function EpiAwareBase.generate_observations(obs_model::TestObs, y_t, Y_t)
        return Y_t
    end

    delay_int = [0.2, 0.3, 0.5]
    obs_model = LatentDelay(TestObs(), delay_int)

    I_t = [10.0, 20.0, 30.0, 40.0, 50.0]
    expected_obs = [missing, missing, 23.0, 33.0, 43.0]

    @testset "Test with entirely missing data" begin
        mdl = generate_observations(obs_model, missing, I_t)
        @test mdl()[1][3:end] == expected_obs[3:end]
        @test sum(mdl()[1] .|> ismissing) == 2
    end

    @testset "Test with missing data defined as a vector" begin
        mdl = generate_observations(
            obs_model, [missing, missing, missing, missing, missing], I_t)
        @test mdl()[1][3:end] == expected_obs[3:end]
        @test sum(mdl()[1] .|> ismissing) == 2
    end

    @testset "Test with data" begin
        pois_obs_model = LatentDelay(PoissonError(), delay_int)
        mdl = generate_observations(pois_obs_model, [10.0, 20.0, 30.0, 40.0, 50.0], I_t)
        @test mdl()[1] == [10.0, 20.0, 30.0, 40.0, 50]
    end
end
