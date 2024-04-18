@testitem "PoissonErrorConstructor" begin
    using Distributions
    # Test default constructor
    poi = PoissonError()
    @test poi.pos_shift ≈ zero(Float64)
    poi_float = PoissonError(; pos_shift = 0f0)
    @test poi_float.pos_shift ≈ zero(Float32)

    # Test constructor with pos_shift
    poi2 = PoissonError(;pos_shift = 1e-3)
    @test poi2.pos_shift ≈ 1e-3
end

@testitem "Testing PoissonError against theoretical properties" begin
    using Distributions, Turing, HypothesisTests, DynamicPPL

    # Set up test parameters
    n = 100  # Number of observations
    μ = 10.0  # Mean of the poisson distribution

    # Define the observation model
    poi_obs_model = PoissonError(pos_shift = 0.0)

    # Generate observations from the model
    Y_t = fill(μ, n)  # True values
    model = generate_observations(poi_obs_model, missing, Y_t)
    samples = sample(model, Prior(), 1000; progress = false)

    obs_samples = samples |>
                  chn -> mapreduce(vcat, generated_quantities(model, chn)) do gen
        gen[1]
    end

    @test isapprox(mean(obs_samples), μ, atol = 0.1)  # Test the mean
end
