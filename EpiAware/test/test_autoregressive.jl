@testitem "Testing AR constructor" begin
    using Distributions, Turing

    damp_prior = truncated(Normal(0.0, 0.05), 0.0, 1)
    std_prior = truncated(Normal(0.0, 0.05), 0.0, Inf)
    init_prior = Normal()
    ar_process = AR(damp_prior, std_prior, init_prior)

    @test ar_process.damp_prior == filldist(damp_prior, 1)
    @test ar_process.std_prior == std_prior
    @test ar_process.init_prior == filldist(init_prior, 1)
end

@testitem "Test AR defaults" begin
    using Distributions
    ar = AR()
    @testset "damp_prior" begin
        damp = rand(ar.damp_prior)
        @test 0.0 <= damp[1] <= 1.0
    end

    @testset "std_prior" begin
        std_AR = rand(ar.std_prior)
        @test std_AR >= 0.0
    end

    @testset "init_prior" begin
        init_ar_value = rand(ar.init_prior)
        @test typeof(init_ar_value[1]) == Float64
    end
end

@testitem "Test AR(2)" begin
    using Distributions
    ar = AR(
        damp_priors = [truncated(Normal(0.0, 0.05), 0.0, 1),
            truncated(Normal(0.0, 0.05), 0.0, 1)],
        std_prior = truncated(Normal(0.0, 0.05), 0.0, Inf),
        init_priors = [Normal(), Normal()]
    )
    @testset "damp_prior" begin
        damp = rand(ar.damp_prior)
        for i in 1:2
            @test 0.0 <= damp[i] <= 1.0
        end
    end

    @testset "std_prior" begin
        std_AR = rand(ar.std_prior)
        @test std_AR >= 0.0
    end

    @testset "init_prior" begin
        init_ar_value = rand(ar.init_prior)
        for i in 1:2
            @test typeof(init_ar_value[i]) == Float64
        end
    end
end

@testitem "Testing AR process against theoretical properties" begin
    using DynamicPPL, Turing
    using HypothesisTests: ExactOneSampleKSTest, pvalue
    using Distributions

    ar_model = AR()
    n = 1000
    damp = [0.1]
    σ_AR = 1.0
    ar_init = [0.0]

    model = generate_latent(ar_model, n)
    fixed_model = fix(model, (σ_AR = σ_AR, damp_AR = damp, ar_init = ar_init))

    n_samples = 100
    samples = sample(fixed_model, Prior(), n_samples, progress = false) |>
              chn -> mapreduce(vcat, generated_quantities(fixed_model, chn)) do gen
        gen[1]
    end

    theoretical_mean = 0.0
    theoretical_var = σ_AR^2 / (1 - damp[1]^2)

    @test isapprox(mean(samples), theoretical_mean, atol = 0.1)
    @test isapprox(var(samples), theoretical_var, atol = 0.2)

    ks_test_pval = ExactOneSampleKSTest(
        samples, Normal(theoretical_mean, sqrt(theoretical_var))) |> pvalue
    @test ks_test_pval > 1e-6
end
