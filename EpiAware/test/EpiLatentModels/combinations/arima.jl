@testitem "Testing ARIMA constructor" begin
    using Distributions, Turing

    # Test default constructor
    arima_model = arima()
    @test arima_model isa DiffLatentModel
    @test arima_model.model isa AR
    @test arima_model.model.ϵ_t isa MA
    @test length(arima_model.model.damp_prior) == 1
    @test length(arima_model.model.init_prior) == 1
    @test length(arima_model.model.ϵ_t.θ) == 1
    @test arima_model.model.damp_prior ==
          filldist(truncated(Normal(0.0, 0.05), 0, 1), 1)
    @test arima_model.model.ϵ_t.θ ==
          filldist(truncated(Normal(0.0, 0.05), -1, 1), 1)

    # Test with custom parameters
    ar_init_prior = Normal(1.0, 0.5)
    diff_init_prior = Normal(0.0, 0.3)
    damp_prior = truncated(Normal(0.0, 0.04), 0, 1)
    θ_prior = truncated(Normal(0.0, 0.06), -1, 1)

    custom_arima = arima(;
        ar_init = [ar_init_prior, ar_init_prior],
        diff_init = [diff_init_prior, diff_init_prior],
        damp = [damp_prior, damp_prior],
        θ = [θ_prior, θ_prior],
        ϵ_t = HierarchicalNormal()
    )

    @test custom_arima isa DiffLatentModel
    @test custom_arima.model isa AR
    @test custom_arima.model.ϵ_t isa MA
    @test length(custom_arima.model.damp_prior) == 2
    @test length(custom_arima.model.init_prior) == 2
    @test length(custom_arima.model.ϵ_t.θ) == 2
    @test custom_arima.model.damp_prior == filldist(damp_prior, 2)
    @test custom_arima.model.init_prior == filldist(ar_init_prior, 2)
    @test custom_arima.model.ϵ_t.θ == filldist(θ_prior, 2)
end

@testitem "Testing ARIMA process against theoretical properties" begin
    using DynamicPPL, Turing
    using HypothesisTests: ExactOneSampleKSTest, pvalue
    using Distributions
    using Statistics

    # Set up simple ARIMA model
    arima_model = arima()
    n = 1000
    damp = [0.1]
    σ_AR = 1.0
    ar_init = [0.0]
    diff_init = [0.0]
    θ = [0.2]  # Add MA component

    # Generate and fix model parameters
    model = generate_latent(arima_model, n)
    fixed_model = fix(model,
        (
            std = σ_AR,
            damp_AR = damp,
            ar_init = ar_init,
            diff_init = diff_init,
            θ = θ
        ))

    # Generate samples
    n_samples = 100
    samples = sample(fixed_model, Prior(), n_samples; progress = false) |>
              chn -> mapreduce(vcat, generated_quantities(fixed_model, chn)) do gen
        gen
    end

    # Compare with pure AR with differencing
    ar_base = AR()
    ar_model = DiffLatentModel(; model = ar_base, init_priors = [Normal()])
    ar_fixed = fix(
        generate_latent(ar_model, n),
        (std = σ_AR, damp_AR = damp, ar_init = ar_init, diff_init = diff_init)
    )

    ar_samples = sample(ar_fixed, Prior(), n_samples; progress = false) |>
                 chn -> mapreduce(vcat, generated_quantities(ar_fixed, chn)) do gen
        gen
    end

    # Test that ARIMA produces different distribution than pure differenced AR
    # This tests that the MA component has an effect
    ks_test = ExactOneSampleKSTest(samples, fit(Normal, ar_samples))
    @test pvalue(ks_test) < 1e-6

    # Test for stationarity of differences
    diff_samples = diff(samples)
    @test isapprox(mean(diff_samples), 0.0, atol = 0.1)
    @test std(diff_samples) > 0
end
