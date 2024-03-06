@testitem "Testing _epi_aware function" begin
    using Transducers, Turing
    time_steps = 20

    y_t = fill(10, time_steps)
    nsamples = 10
    nchains = 2
    pf_ndraws = 10
    pf_nruns = 10
    fixed_parameters = (;)
    pos_shift = 1e-6
    executor = Transducers.ThreadedEx()
    adtype = AutoReverseDiff(true)
    maxiters = 10

    #Define the epi_model
    epi_model = DirectInfections(EpiData([0.2, 0.3, 0.5], exp), Normal())

    #Define the latent process model
    rwp = EpiAware.RandomWalk(Normal(0.0, 1.0),
        truncated(Normal(0.0, 0.05), 0.0, Inf))

    #Define the observation model
    delay_distribution = Gamma(2.0, 5 / 2)
    time_horizon = time_steps
    D_delay = 14.0
    Δd = 1.0

    obs_model = EpiAware.DelayObservations(delay_distribution = delay_distribution,
        time_horizon = time_horizon,
        neg_bin_cluster_factor_prior = Gamma(5, 0.05 / 5),
        D_delay = D_delay,
        Δd = Δd)

    # Call the _epi_aware function to check this runs
    chn, results = EpiAware._epi_aware(y_t, time_steps;
        epi_model = epi_model,
        latent_model = rwp,
        observation_model = obs_model,
        nsamples = nsamples,
        nchains = nchains,
        pf_ndraws = pf_ndraws,
        pf_nruns = pf_nruns,
        fixed_parameters = fixed_parameters,
        pos_shift = pos_shift,
        executor = executor,
        adtype = adtype,
        maxiters = maxiters)

    # Perform assertions to check the correctness of the results
    @test size(chn, 1) == nsamples ÷ nchains
    @test haskey(results, :pathfinder_res)
    @test haskey(results, :inference_mdl)
    @test haskey(results, :generative_mdl)
end
