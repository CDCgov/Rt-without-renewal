@testitem "NegativeBinomialErrorConstructor" begin
    using Distributions
    # Test default constructor
    nb = NegativeBinomialError()
    @test nb.cluster_factor_prior isa HalfNormal{Float64}
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

@testset "Testing NegativeBinomialError against theoretical properties" begin
    using Distributions, Turing, HypothesisTests

    # Set up test parameters
    n = 10  # Number of observations
    μ = 10.0  # Mean of the negative binomial distribution
    α = 0.05  # Cluster factor (dispersion parameter)

    # Define the observation model
    nb_obs_model = NegativeBinomialError()

    # Generate observations from the model
    Y_t = fill(μ, n)  # True values
    model = generate_observations(nb_obs_model, missing, Y_t)ww
    fix_model = fix(model, (cluster_factor = α))
    samples = sample(model, Prior(), 1000)

    # Test the mean and variance of the observations
    obs_samples = [s[1] for s in samples]
    @test isapprox(mean(obs_samples), μ, atol = 0.1)  # Test the mean
    @test isapprox(var(obs_samples), μ + α^2 * μ^2, atol = 0.1)  # Test the variance

    # Test the distribution of the observations
    theoretical_dist = NegativeBinomialMeanClust(μ, α^2)
    ks_test = ExactOneSampleKSTest(obs_samples, theoretical_dist)
    @test pvalue(ks_test) > 0.05  # Fail to reject the null hypothesis at 5% significance level
end
