let
    using Distributions
    using LogExpFunctions
    suite["single-timeseries"] = BenchmarkGroup()
    # Dummy data
    expected_cases = [1000 * exp(-(t - 15)^2 / (2 * 4)) for t in 1:30] .|> round

    # Renewal model
    let
        simple_renewal = EpiProblem(
            epi_model = Renewal(;
                data = EpiData(;
                    gen_distribution = LogNormal(1.3, 0.2)
                )
            ),
            latent_model = broadcast_weekly(RandomWalk()),
            observation_model = LatentDelay(
                Ascertainment(
                    PoissonError(),
                    HierarchicalNormal(-0.1, truncated(Normal(0, 0.1), 0, Inf)),
                    x -> logistic.(x)
                ),
                LogNormal(1.6, 0.4)
            ),
            tspan = (1, 30)
        )

        renewal_mdl = generate_epiaware(simple_renewal, (y_t = expected_cases,))
        suite["renewal"] = make_turing_suite(renewal_mdl; check = true)
    end

    # Population bounded renewal
    let
        pop_renewal = EpiProblem(
            epi_model = RenewalWithPopulation(
                data = EpiData(
                    gen_distribution = truncated(Normal(1.3, 0.7), 0, Inf)
                ),
                initialisation_prior = Normal(0, 1),
                pop_size = 10000.0
            ),
            latent_model = broadcast_weekly(DiffLatentModel(AR(), [Normal(0, 1)])),
            observation_model = LatentDelay(
                Ascertainment(
                    model = NegativeBinomialError(),
                    latent_model = ConcatLatentModels(
                        [
                        Intercept(Normal(2, 0.2)),
                        HierarchicalNormal(
                            -0.1, truncated(Normal(0, 0.1), 0, Inf)
                        )
                    ]
                    ),
                    link = x -> logistic.(x)
                ),
                LogNormal(1.9, 0.2)
            ),
            tspan = (1, 30)
        )
        pop_renewal_mdl = generate_epiaware(pop_renewal, (y_t = expected_cases,))
        suite["populaton bounded renewal"] = make_turing_suite(
            pop_renewal_mdl; check = true)
    end

    # Growth rate model
    let
        growth = EpiProblem(
            epi_model = ExpGrowthRate(
                data = EpiData(
                    gen_distribution = truncated(Normal(1.3, 0.7), 0, Inf)
                ),
                initialisation_prior = Normal(0, 1)
            ),
            latent_model = broadcast_weekly(RandomWalk()),
            observation_model = LatentDelay(
                Ascertainment(
                    model = NegativeBinomialError(),
                    latent_model = CombineLatentModels(
                        [
                        broadcast_dayofweek(
                            HierarchicalNormal(
                                -0.1, truncated(Normal(0, 0.1), 0, Inf)
                            ); link = x -> x
                        ),
                        HierarchicalNormal(
                            -0.1, truncated(Normal(0, 0.1), 0, Inf)
                        )
                    ]
                    ),
                    link = x -> logistic.(x)
                ),
                LogNormal(2, 0.2)
            ),
            tspan = (1, 30)
        )
        growth_mdl = generate_epiaware(growth, (y_t = expected_cases,))
        # suite["growth"] = make_turing_suite(growth_mdl; check = true)
    end
    # Log infections
    let
        log_infections = EpiProblem(
            epi_model = DirectInfections(
                data = EpiData(
                    gen_distribution = LogNormal(2, 0.2)
                ),
                initialisation_prior = Normal(0, 1)
            ),
            latent_model = CombineLatentModels(
                [
                DiffLatentModel(
                    AR(
                        truncated(Normal(0, 0.1), 0, 1),
                        truncated(Normal(0, 0.01), 0, Inf),
                        Normal(0, 1);
                        p = 3
                    ),
                    [Normal(0, 1), Normal(0, 1)]
                ),
                broadcast_dayofweek(
                    HierarchicalNormal(
                    0, truncated(Normal(0, 0.1), 0, Inf)
                )
                )
            ]
            ),
            observation_model = LatentDelay(PoissonError(), LogNormal(2.3, 0.4)),
            tspan = (1, 30)
        )
        log_infections_mdl = generate_epiaware(log_infections, (y_t = expected_cases,))
        suite["log infections"] = make_turing_suite(log_infections_mdl; check = true)
    end
end
