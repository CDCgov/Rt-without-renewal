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

@testitem "LatentDelay parameter recovery with mix of IGP + latent processes: Poisson errors + EpiProblem interface" begin
    using Random, Turing, Distributions, LinearAlgebra, DynamicPPL, StatsBase, ReverseDiff,
          Suppressor, LogExpFunctions
    # using PairPlots, CairoMakie
    Random.seed!(1234)

    #Set up model testing matrix

    epimodels = [
        DirectInfections,
        ExpGrowthRate,
        Renewal] .|>
                em_type -> em_type(
        data = EpiData([0.2, 0.5, 0.3],
            em_type == Renewal ? softplus : exp
        ),
        initialisation_prior = Normal(log(100.0), 0.01)
    )

    latentprocess_types = [RandomWalk, AR, DiffLatentModel]

    function set_init_and_std_prior(epimodel)
        if epimodel isa Renewal
            init_prior = Normal(log(1.2), 0.25)
            std_prior = HalfNormal(0.05)
            return (; init_prior, std_prior)
        elseif epimodel isa ExpGrowthRate
            init_prior = Normal(0.1, 0.025)
            std_prior = LogNormal(log(0.025), 0.01)
            return (; init_prior, std_prior)
        elseif epimodel isa DirectInfections
            init_prior = Normal(log(100.0), 0.25)
            std_prior = HalfNormal(0.025)
            return (; init_prior, std_prior)
        end
    end

    function set_latent_process(epimodel, latentprocess_type)
        init_prior, std_prior = set_init_and_std_prior(epimodel)
        if latentprocess_type == RandomWalk
            return RandomWalk(init_prior, std_prior)
        elseif latentprocess_type == AR
            return AR(damp_priors = [Beta(2, 8; check_args = false)],
                std_prior = std_prior, init_priors = [init_prior])
        elseif latentprocess_type == DiffLatentModel
            return DiffLatentModel(
                AR(damp_priors = [Beta(2, 8; check_args = false)],
                    std_prior = std_prior, init_priors = [Normal(0.0, 0.25)]),
                init_prior; d = 1)
        end
    end

    function test_full_process(epimodel, latentprocess, n;
            ad = AutoReverseDiff(; compile = true), posterior_p_tol = 0.005)
        #Fix observation model
        obs = LatentDelay(PoissonError(), Gamma(3, 7 / 3))

        #Inference method
        inference_method = EpiMethod(
            pre_sampler_steps = [ManyPathfinder(nruns = 4, maxiters = 50)],
            sampler = NUTSampler(adtype = ad,
                ndraws = 2000,
                nchains = 2,
                mcmc_parallel = MCMCThreads())
        )

        epi_prob = EpiProblem(
            epi_model = epimodel,
            latent_model = latentprocess,
            observation_model = obs,
            tspan = (1, n)
        )

        #Generate data from generative model (i.e. data unconditioned)
        generative_mdl = generate_epiaware(epi_prob, (y_t = missing,))
        θ_true = rand(generative_mdl)
        gen_data = condition(generative_mdl, θ_true)()

        #Apply inference method to inference model (i.e. generative model conditioned on data)
        inference_results = apply_method(epi_prob,
            inference_method,
            (y_t = gen_data.generated_y_t,);
            progress = false
        )

        chn = inference_results.samples

        #Check that true parameters are within 99% central posterior probability
        @testset for param in keys(θ_true)
            if param ∈ keys(chn)
                posterior_p = ecdf(chn[param][:])(θ_true[param])
                @test 0.5 * posterior_p_tol < posterior_p < 1 - 0.5 * posterior_p_tol
            end
        end

        return θ_true, gen_data, chn, generative_mdl
    end

    #Test the parameter recovery for all combinations of latent processes and epi models
    @testset "Check true parameters are within 99% central post. prob.: " begin
        @testset for latentprocess_type in latentprocess_types, epimodel in epimodels
            latentprocess = set_latent_process(epimodel, latentprocess_type)
            @suppress _ = test_full_process(epimodel, latentprocess, 40)
        end
    end
end
