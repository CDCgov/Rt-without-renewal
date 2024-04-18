@testitem "NegativeBinomialErrorConstructor" begin
    using Distributions
    # Test default constructor
    nb = NegativeBinomialError()
    @test all(rand(nb.cluster_factor_prior, 100) .>= 0.0)
    @test isapprox(mean(nb.cluster_factor_prior), 0.01)
    @test nb.pos_shift ≈ 1e-6

    # Test constructor with custom prior
    prior = Gamma(2.0, 1.0)
    nb = NegativeBinomialError(prior)
    @test nb.cluster_factor_prior == prior
    @test nb.pos_shift ≈ 1e-6

    # Test constructor with custom prior and pos_shift
    nb = NegativeBinomialError(prior; pos_shift = 1e-3)
    @test nb.cluster_factor_prior == prior
    @test nb.pos_shift ≈ 1e-3
end

@testitem "Testing NegativeBinomialError against theoretical properties" begin
    using Distributions, Turing, HypothesisTests, DynamicPPL

    # Set up test parameters
    n = 100  # Number of observations
    μ = 10.0  # Mean of the negative binomial distribution
    α = 0.2  # Cluster factor (dispersion parameter)

    # Define the observation model
    nb_obs_model = NegativeBinomialError(pos_shift = 0.0)

    # Generate observations from the model
    Y_t = fill(μ, n)  # True values
    model = generate_observations(nb_obs_model, missing, Y_t)
    fix_model = fix(model, (cluster_factor = α))
    samples = sample(fix_model, Prior(), 1000; progress = false)

    obs_samples = samples |>
        chn -> mapreduce(vcat, generated_quantities(fix_model, chn)) do gen
        gen[1]
    end

    @test isapprox(mean(obs_samples), μ, atol = 0.1)  # Test the mean
    @test isapprox(var(obs_samples), μ + α^2 * μ^2, atol = 0.2)  # Test the variance
end
