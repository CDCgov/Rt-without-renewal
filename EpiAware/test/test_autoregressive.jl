@testitem "Testing default_ar_priors" begin
    using Distributions

    @testset "damp_prior" begin
        priors = EpiAware.default_ar_priors()
        damp = rand(priors[:damp_prior][1])
        @test 0.0 <= damp <= 1.0
    end

    @testset "var_prior" begin
        priors = EpiAware.default_ar_priors()
        var_AR = rand(priors[:var_prior])
        @test var_AR >= 0.0
    end

    @testset "init_prior" begin
        priors = EpiAware.default_ar_priors()
        init_ar_value = rand(priors[:init_prior])
        @test typeof(init_ar_value) == Float64
    end
end

@testitem "Testing AR constructor" begin
    using Distributions

    damp_prior = [truncated(Normal(0.0, 0.05), 0.0, 1)]
    var_prior = truncated(Normal(0.0, 0.05), 0.0, Inf)
    init_prior = Normal()
    ar_process = EpiAware.AR(damp_prior, var_prior, init_prior)

    @test ar_process.damp_prior == damp_prior
    @test ar_process.var_prior == var_prior
    @test ar_process.init_prior == init_prior
    @test ar_process.p == 1
end

@testitem "Testing AR process against theoretical properties" begin
    using DynamicPPL, Turing
    using HypothesisTests: ExactOneSampleKSTest, pvalue
    using Distributions

    ar_model = EpiAware.AR(EpiAware.default_ar_priors()[:damp_prior],
        EpiAware.default_ar_priors()[:var_prior],
        EpiAware.default_ar_priors()[:init_prior]
    )
    n = 1000
    damp = [0.1]
    σ²_AR = 1.0
    ar_init = [0.0]

    model = EpiAware.generate_latent(ar_model, n)
    fixed_model = fix(model, (σ²_AR = σ²_AR, damp_AR = damp, ar_init = ar_init))

    n_samples = 100
    samples = sample(fixed_model, Prior(), n_samples) |>
              chn -> mapreduce(vcat, generated_quantities(fixed_model, chn)) do gen
        gen[1]
    end

    theoretical_mean = 0.0
    theoretical_var = σ²_AR / (1 - damp[1]^2)

    @test isapprox(mean(samples), theoretical_mean, atol = 0.1)
    @test isapprox(var(samples), theoretical_var, atol = 0.2)

    ks_test_pval = ExactOneSampleKSTest(
        samples, Normal(theoretical_mean, sqrt(theoretical_var))) |> pvalue
    @test ks_test_pval > 1e-6
end
