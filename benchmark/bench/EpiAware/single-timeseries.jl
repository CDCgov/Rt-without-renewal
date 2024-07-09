let
    using Distributions
    using LogExpFunctions
    suite["single-timeseries"] = BenchmarkGroup()
    # Dummy data
    expected_cases = [
        1000 * exp(-(t - 15)^2 / (2 * 4)) for t in 1:30
    ] .|> round



# Renewal model
    # Renewal model
    # Weekly random walk
    # Ascertainment
        # Hiearchical normal
    # Latent Delay
    # Poisson
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

    mdl = generate_epiaware(simple_renewal, (y_t = expected_cases,))
    suite["renewal"] = make_turing_suite(mdl; check = true)

# Population bounded renewa
    # Population bounded renewal
    # Weekly differenced AR
    # Ascertainment
        # Concat two intercepts
    # Negative binomial
    pop_renewal = EpiProblem(
        epi_model = RenewalWithPopulation(
            data = EpiData(
                gen_distribution = truncated(Normal(1.3, 0.7), 0, Inf)
            ),
            pop_size = 10000
        ),
        latent_model = broadcast_weekly(DiffLatentModel(AR(), [Normal(0, 1)])),
        observation_model = Ascertainment(
            NegativeBinomialError(),
            ConcatLatentModels([Intercept(Normal(2, 0.2)), FixedIntercept(0.2)]),
            x -> logistic.(x)
        )
    )
# Growth rate model
    # Growth rate model
    # Weekly random walk
    # Ascertainment
        # Day of week hiearchical normal
    # Negative binomial

# Direct infections
    # Direct infections
    # Daily differenced AR
    # Ascertainment
        # Day of week hiearchical normal + Intercerpt
    # Latent delay
    # Poisson
