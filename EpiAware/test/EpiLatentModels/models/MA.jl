@testitem "Testing MA constructor" begin
    using Distributions, Turing

    θ_prior = truncated(Normal(0.0, 0.05), -1, 1)
    ma_process = MA(θ_prior; q = 1, ϵ_t = HierarchicalNormal())

    @test ma_process.q == 1
    @test ma_process.ϵ_t isa HierarchicalNormal
    @test length(ma_process.θ) == 1
end

@testitem "Test MA(2)" begin
    using Distributions, Turing
    θ_prior = truncated(Normal(0.0, 0.05), -1, 1)
    ma = MA(;
        θ_priors = [θ_prior, θ_prior],
        ϵ_t = HierarchicalNormal()
    )
    @test ma.q == 2
    @test ma.ϵ_t isa HierarchicalNormal
    @test length(ma.θ) == 2
end

@testitem "Testing MA process against theoretical properties" begin
    using DynamicPPL, Turing
    using HypothesisTests: ExactOneSampleKSTest, pvalue
    using Distributions

    # Test MA(1) process
    θ = [0.1]
    @testset "MA(1) with θ = $θ" begin
        ma_model = MA(; θ_priors = [truncated(Normal(0.0, 0.05), -1, 1)],
            ϵ_t = IID(Normal()))
        n = 1000
        model = generate_latent(ma_model, n)
        fixed_model = fix(model, (θ = θ,))

        n_samples = 100
        samples = sample(fixed_model, Prior(), n_samples; progress = false) |>
                  chn -> mapreduce(vcat, generated_quantities(fixed_model, chn)) do gen
            gen
        end

        # For MA(1), mean should be 0
        @test isapprox(mean(samples), 0.0, atol = 0.1)

        # For MA(1) with standard normal errors, variance is 1 + θ^2
        theoretical_var = 1 + sum(θ .^ 2)
        @test isapprox(var(samples), theoretical_var, atol = 0.2)

        # Test distribution is approximately normal
        ks_test = ExactOneSampleKSTest(
            samples, Normal(0.0, sqrt(theoretical_var)))
        @test pvalue(ks_test) > 1e-6
    end

    # Test MA(2) process
    θ = [0.3, 0.2]
    @testset "MA(2) with θ = $θ" begin
        ma_model = MA(; θ_priors = fill(truncated(Normal(0.0, 0.05), -1, 1), 2),
            ϵ_t = IID(Normal()))
        n = 1000
        model = generate_latent(ma_model, n)
        fixed_model = fix(model, (θ = θ,))

        n_samples = 100
        samples = sample(fixed_model, Prior(), n_samples; progress = false) |>
                  chn -> mapreduce(vcat, generated_quantities(fixed_model, chn)) do gen
            gen
        end

        # For MA(2), mean should be 0
        @test isapprox(mean(samples), 0.0, atol = 0.1)

        # For MA(2) with standard normal errors, variance is 1 + θ_1^2 + θ_2^2
        theoretical_var = 1 + sum(θ .^ 2)
        @test isapprox(var(samples), theoretical_var, atol = 0.2)

        # Test distribution is approximately normal
        ks_test = ExactOneSampleKSTest(
            samples, Normal(0.0, sqrt(theoretical_var)))
        @test pvalue(ks_test) > 1e-6
    end
end
