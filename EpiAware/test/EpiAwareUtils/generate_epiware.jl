
@testitem "`generate_epiaware` with direct infections and RW latent process runs" begin
    using Distributions, Turing, DynamicPPL
    # Define test inputs
    y_t = missing # Data will be generated from the model
    data = EpiData([0.2, 0.3, 0.5], exp)
    pos_shift = 1e-6
    time_horizon = 100

    #Define the epi_model
    epi_model = DirectInfections(data, Normal())

    #Define the latent process model
    rwp = RandomWalk(Normal(0.0, 1.0),
        truncated(Normal(0.0, 0.05), 0.0, Inf))

    #Define the observation model
    delay_distribution = Gamma(2.0, 5 / 2)
    Δd = 1.0

    obs_model = LatentDelay(
        NegativeBinomialError(cluster_factor_prior = Gamma(5, 0.05 / 5)),
        delay_distribution, D = 14, Δd = Δd
    )

    # Create full epi model and sample from it
    test_mdl = generate_epiaware(
        y_t, time_horizon, epi_model,
        latent_model = rwp,
        observation_model = obs_model
    )
    gen = generated_quantities(test_mdl, rand(test_mdl))

    #Check model sampled
    @test eltype(gen.generated_y_t) <: Int
    @test eltype(gen.I_t) <: AbstractFloat
    @test length(gen.I_t) == time_horizon
end

@testitem "`generate_epiaware` with Exp growth rate and RW latent process runs" begin
    using Distributions, Turing, DynamicPPL
    # Define test inputs
    y_t = missing# rand(1:10, 365) # Data will be generated from the model
    data = EpiData([0.2, 0.3, 0.5], exp)
    pos_shift = 1e-6

    #Define the epi_model
    epi_model = ExpGrowthRate(data, Normal())

    #Define the latent process model
    r_3 = log(2) / 3.0
    rwp = RandomWalk(
        truncated(Normal(0.0, r_3 / 3), -r_3, r_3), # 3 day doubling time at 3 sigmas in prior
        truncated(Normal(0.0, 0.01), 0.0, 0.1))

    #Define the observation model - no delay model
    time_horizon = 5
    obs_model = NegativeBinomialError(
        truncated(Gamma(5, 0.05 / 5), 1e-3, 1.0); pos_shift
    )

    # Create full epi model and sample from it
    test_mdl = generate_epiaware(y_t,
        time_horizon,
        epi_model;
        latent_model = rwp,
        observation_model = obs_model)

    chn = sample(test_mdl, Prior(), 1000; progress = false)
    gens = generated_quantities(test_mdl, chn)

    #Check model sampled
    @test eltype(gens[1].generated_y_t) <: Int
    @test eltype(gens[1].I_t) <: AbstractFloat
    @test length(gens[1].I_t) == time_horizon
end

@testitem "`generate_epiaware` with Renewal and RW latent process runs" begin
    using Distributions, Turing, DynamicPPL
    # Define test inputs
    y_t = missing# rand(1:10, 365) # Data will be generated from the model
    data = EpiData([0.2, 0.3, 0.5], exp)
    pos_shift = 1e-6

    #Define the epi_model
    epi_model = Renewal(data, Normal())

    #Define the latent process model
    r_3 = log(2) / 3.0
    rwp = RandomWalk(
        truncated(Normal(0.0, r_3 / 3), -r_3, r_3), # 3 day doubling time at 3 sigmas in prior
        truncated(Normal(0.0, 0.01), 0.0, 0.1))

    #Define the observation model - no delay model
    time_horizon = 5
    obs_model = NegativeBinomialError(
        truncated(Gamma(5, 0.05 / 5), 1e-3, 1.0);
        pos_shift
    )

    # Create full epi model and sample from it
    test_mdl = generate_epiaware(y_t,
        time_horizon,
        epi_model;
        latent_model = rwp,
        observation_model = obs_model
    )

    chn = sample(test_mdl, Prior(), 1000; progress = false)
    gens = generated_quantities(test_mdl, chn)

    #Check model sampled
    @test eltype(gens[1].generated_y_t) <: Int
    @test eltype(gens[1].I_t) <: AbstractFloat
    @test length(gens[1].I_t) == time_horizon
end
