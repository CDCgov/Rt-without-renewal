@testitem "Testing IID constructor" begin
    using Distributions, Turing

    normal_prior = Normal(0.0, 1.0)
    idd_process = IID(normal_prior)

    @test idd_process.ϵ_t == normal_prior
end

@testitem "Test IID defaults" begin
    using Distributions
    idd = IID()
    @test idd.ϵ_t == Normal(0, 1)
end

@testitem "Test IID with different distributions" begin
    using Distributions

    @testset "Uniform distribution" begin
        idd = IID(Uniform(0, 1))
        sample = rand(idd.ϵ_t)
        @test 0 <= sample <= 1
    end

    @testset "Exponential distribution" begin
        idd = IID(Exponential(1))
        sample = rand(idd.ϵ_t)
        @test sample >= 0
    end
end

@testitem "Testing IID process against theoretical properties" begin
    using DynamicPPL, Turing
    using HypothesisTests: ExactOneSampleKSTest, pvalue
    using Distributions

    idd_model = IID(Normal(2, 3))
    n = 1000

    model = generate_latent(idd_model, n)

    n_samples = 100
    samples = sample(model, Prior(), n_samples; progress = false) |>
              chn -> mapreduce(vcat, generated_quantities(model, chn)) do gen
        gen
    end

    theoretical_mean = 2.0
    theoretical_var = 3.0^2

    @test isapprox(mean(samples), theoretical_mean, atol = 0.1)
    @test isapprox(var(samples), theoretical_var, atol = 0.2)

    ks_test_pval = ExactOneSampleKSTest(
        samples, Normal(theoretical_mean, sqrt(theoretical_var))) |> pvalue
    @test ks_test_pval > 1e-6
end
