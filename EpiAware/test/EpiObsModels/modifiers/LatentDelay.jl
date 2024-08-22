@testitem "Testing LatentDelay struct" begin
    using Distributions

    # Define a dummy observation model for testing
    struct DummyObservationModel <: AbstractTuringObservationModel end
    dummy_model = DummyObservationModel()

    # Test case 1
    delay_int = [0.2, 0.3, 0.5]
    obs_model = LatentDelay(dummy_model, delay_int)

    @test obs_model.model == dummy_model
    @test obs_model.rev_pmf == reverse(delay_int)

    # Test case 2
    delay_distribution = Uniform(0.0, 20.0)
    D_delay = 10.0
    Δd = 1.0

    obs_model = LatentDelay(dummy_model, delay_distribution, D = D_delay, Δd = Δd)

    @test obs_model.model == dummy_model
    @test length(obs_model.rev_pmf) == D_delay

    # Test case 3: check default right truncation
    delay_distribution = Gamma(3, 15 / 3)
    D_delay = nothing
    Δd = 1.0

    obs_model = LatentDelay(dummy_model, delay_distribution, D = D_delay, Δd = Δd)

    nn_perc_rounded = invlogcdf(delay_distribution, log(0.99)) |> x -> round(Int64, x)
    @test length(obs_model.rev_pmf) == nn_perc_rounded
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
                       (gen -> gen[1]) |>
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
    expected_obs = [missing, missing, 17.0, 27.0, 37.0]

    @testset "Test with entirely missing data" begin
        mdl = generate_observations(obs_model, missing, I_t)
        @test mdl() == expected_obs[3:end]
        @test sum(mdl() .|> ismissing) == 0
    end

    @testset "Test with missing data defined as a vector" begin
        mdl = generate_observations(
            obs_model, [missing, missing, missing, missing, missing], I_t)
        @test mdl() == expected_obs[3:end]
        @test sum(mdl() .|> ismissing) == 0
    end

    @testset "Test with a real observation error model" begin
        using Turing, DynamicPPL
        pois_obs_model = LatentDelay(RecordExpectedObs(PoissonError()), delay_int)
        missing_mdl = generate_observations(pois_obs_model, missing, I_t)
        missing_draws = missing_mdl() |> Vector{Union{Int, Missing}}
        @test all(ismissing.(missing_draws[1:2]))
        @test !any(ismissing.(missing_draws[3:end]))

        mdl = generate_observations(pois_obs_model, [10, 20, 30, 40, 50], I_t)
        @test mdl() == [10, 20, 30, 40, 50]
        samples = sample(mdl, Prior(), 10; progress = false)
        exp_y_t = get(samples, :exp_y_t).exp_y_t
        @test exp_y_t[1][1] == expected_obs[3]
        @test exp_y_t[2][1] == expected_obs[4]
        @test exp_y_t[3][1] == expected_obs[5]
    end
end

@testitem "LatentDelay parameter recovery with log-RW latent process: Negative binomial errors" begin
    using Random, Turing, Distributions, LinearAlgebra, DynamicPPL, StatsBase,
          ReverseDiff, LogDensityProblems, LogDensityProblemsAD
    Random.seed!(1234)

    latent_process = RandomWalk(
        init_prior = Normal(log(100.0), 0.25), std_prior = HalfNormal(0.25))
    obs_error_model = NegativeBinomialError(cluster_factor_prior = HalfNormal(0.05))
    d_delay = Gamma(3, 7 / 3)
    obs_model = LatentDelay(obs_error_model, d_delay)

    @model function test_negbin_errors_with_delays(rw, obs, y_t)
        n = length(y_t)
        @submodel Z_t = generate_latent(rw, n)
        @submodel gen_y_t = generate_observations(obs, y_t, exp.(Z_t))
        return exp.(Z_t), gen_y_t
    end

    #Generate data from model
    generative_mdl = test_negbin_errors_with_delays(
        latent_process, obs_model, Vector{Union{Missing, Int}}(undef, 50))
    θ_true = rand(generative_mdl)
    Z_t_obs, y_t_obs = condition(generative_mdl, θ_true)()

    #Sample from model conditional on data
    mdl = test_negbin_errors_with_delays(latent_process, obs_model, y_t_obs)
    ad = AutoReverseDiff(; compile = true)
    chn = sample(mdl, NUTS(adtype = ad), MCMCThreads(), 1000, 4, progess = false)

    @testset "Check model vals and grads agree across AD systems for random param choice" begin
        ℓ = DynamicPPL.LogDensityFunction(mdl)
        DynamicPPL.link!!(ℓ.varinfo, mdl)

        n = LogDensityProblems.dimension(ℓ)
        LogDensityProblems.logdensity(ℓ, zeros(n))
        ∇ℓ_rd = LogDensityProblemsAD.ADgradient(Val(:ReverseDiff), ℓ)
        ∇ℓ_rd2 = ADgradient(:ReverseDiff, ℓ; compile = Val(true))
        ∇ℓ_fd = LogDensityProblemsAD.ADgradient(Val(:ForwardDiff), ℓ)

        x = randn(n)
        val1, g1 = LogDensityProblems.logdensity_and_gradient(∇ℓ_rd, x)
        val2, g2 = LogDensityProblems.logdensity_and_gradient(∇ℓ_fd, x)
        val3, g3 = LogDensityProblems.logdensity_and_gradient(∇ℓ_rd2, x)

        @test val1 ≈ val2 ≈ val3
        @test g1 ≈ g2 ≈ g3
    end

    #Check that are in central 99.9% of the posterior predictive distribution
    #Therefore, this should be unlikely to fail if the model is correctly implemented
    @testset "Check true parameters are within 99.9% central post. prob.: " begin
        params_to_check = keys(θ_true)
        @testset for param in params_to_check
            if param ∈ keys(chn)
                posterior_p = ecdf(chn[param][:])(θ_true[param])
                @test 0.0005 < posterior_p < 0.9995
            end
        end
    end
end

@testitem "LatentDelay parameter recovery with Renewal + RW latent process: Negative binomial errors + EpiProblem interface" begin
    using Random, Turing, Distributions, LinearAlgebra, DynamicPPL, StatsBase,
          ReverseDiff, LogDensityProblems, LogDensityProblemsAD
    Random.seed!(1234)

    latent_process = RandomWalk(
        init_prior = Normal(log(1.2), 0.25), std_prior = HalfNormal(0.05))
    obs_error_model = NegativeBinomialError(cluster_factor_prior = HalfNormal(0.05))
    d_delay = Gamma(3, 7 / 3)
    obs_model = LatentDelay(obs_error_model, d_delay)
    gen_int = [0.2, 0.3, 0.5]
    data = EpiData(gen_int, exp)
    renewal_model = Renewal(data = data, initialisation_prior = Normal(log(10.0), 0.25))

    # Using the EpiProblem interface
    epi_prob = EpiProblem(
        epi_model = renewal_model,
        latent_model = latent_process,
        observation_model = obs_model,
        tspan = (1, 50)
    )

    generative_mdl = generate_epiaware(
        epi_prob, (y_t = Vector{Union{Int, Missing}}(missing, 50),))
    θ_true = rand(generative_mdl)
    gen_data = condition(generative_mdl, θ_true)()

    using StatsPlots
    scatter(gen_data.generated_y_t, label = "Observed data", legend = :topleft)

    ad = AutoReverseDiff(; compile = true)

    inference_method = EpiMethod(
        pre_sampler_steps = [ManyPathfinder(nruns = 4, maxiters = 100)],
        sampler = NUTSampler(adtype = ad,
            ndraws = 1000,
            nchains = 4,
            mcmc_parallel = MCMCThreads())
    )

    inference_results = apply_method(epi_prob,
        inference_method,
        (y_t = gen_data.generated_y_t,)
    )

    # chn2 = sample(mdl, NUTS(adtype = ad), 1000, progess = false)
    @testset "Check model vals and grads agree across AD systems for random param choice" begin
        mdl = generate_epiaware(epi_prob, (y_t = gen_data.generated_y_t,))

        ℓ = DynamicPPL.LogDensityFunction(inference_results.model)
        DynamicPPL.link!!(ℓ.varinfo, mdl)

        n = LogDensityProblems.dimension(ℓ)
        LogDensityProblems.logdensity(ℓ, zeros(n))
        ∇ℓ_rd = LogDensityProblemsAD.ADgradient(Val(:ReverseDiff), ℓ)
        ∇ℓ_rd2 = ADgradient(:ReverseDiff, ℓ; compile = Val(true))
        ∇ℓ_fd = LogDensityProblemsAD.ADgradient(Val(:ForwardDiff), ℓ)

        x = randn(n)
        val1, g1 = LogDensityProblems.logdensity_and_gradient(∇ℓ_rd, x)
        val2, g2 = LogDensityProblems.logdensity_and_gradient(∇ℓ_fd, x)
        val3, g3 = LogDensityProblems.logdensity_and_gradient(∇ℓ_rd2, x)

        @test val1 ≈ val2 ≈ val3
        @test g1 ≈ g2 ≈ g3
    end

    chn = inference_results.samples
    @testset "Check true parameters are within 99.9% central post. prob.: " begin
        params_to_check = keys(θ_true)
        @testset for param in params_to_check
            if param ∈ keys(chn)
                posterior_p = ecdf(chn[param][:])(θ_true[param])
                @test 0.0005 < posterior_p < 0.9995
            end
        end
    end
end
