@testitem "Testing MA constructor" begin
    using Distributions, Turing

    θ_prior = truncated(Normal(0.0, 0.05), -1, 1)
    σ_prior = HalfNormal(0.1)
    ma_process = MA(θ_prior, σ_prior)

    @test ma_process.θ_prior == filldist(θ_prior, 1)
    @test ma_process.σ_prior == σ_prior
    @test ma_process.q == 1
    @test ma_process.ϵ_t isa IDD
end

@testitem "Test MA(2)" begin
    using Distributions, Turing
    θ_prior = truncated(Normal(0.0, 0.05), -1, 1)
    ma = MA(
        θ_priors = [θ_prior, θ_prior],
        σ_prior = HalfNormal(0.1)
    )
    @test ma.q == 2
    @test ma.ϵ_t isa IDD
    @test ma.θ_prior == filldist(θ_prior, 2)
end

@testitem "Testing MA process against theoretical properties" begin
    using DynamicPPL, Turing
    using HypothesisTests: ExactOneSampleKSTest, pvalue
    using Distributions

    ma_model = MA()
    n = 1000
    θ = [0.1]
    σ = 1.0

    model = generate_latent(ma_model, n)
    fixed_model = fix(model, (σ = σ, θ = θ))

    n_samples = 100
    samples = sample(fixed_model, Prior(), n_samples; progress = false) |>
              chn -> mapreduce(vcat, generated_quantities(fixed_model, chn)) do gen
        gen
    end

    theoretical_mean = 0.0
    theoretical_var = σ^2 * (1 + sum(θ .^ 2))

    @test isapprox(mean(samples), theoretical_mean, atol = 0.1)
    @test isapprox(var(samples), theoretical_var, atol = 0.2)

    ks_test_pval = ExactOneSampleKSTest(
        samples, Normal(theoretical_mean, sqrt(theoretical_var))) |> pvalue
    @test ks_test_pval > 1e-6
end
