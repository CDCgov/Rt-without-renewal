@testitem "HierarchicalNormal constructor" begin
    using Distributions
    int = HierarchicalNormal(0.1, truncated(Normal(0, 2), 0, Inf))
    @test typeof(int) <: AbstractTuringLatentModel
    @test int.mean == 0.1
    @test int.std_prior == truncated(Normal(0, 2), 0, Inf)

    int_def = HierarchicalNormal()
    @test typeof(int_def) <: AbstractTuringLatentModel
    @test int_def.mean == 0.0
    @test int_def.std_prior == truncated(Normal(0, 0.1), 0, Inf)

    @test int == HierarchicalNormal(mean = 0.1, std_prior = truncated(Normal(0, 2), 0, Inf))
end

@testitem "HierarchicalNormal generate_latent" begin
    using DynamicPPL, Turing
    using HypothesisTests: ExactOneSampleKSTest, pvalue
    using Distributions

    hnorm = HierarchicalNormal(0.2, truncated(Normal(0, 1), 0, Inf))
    hnorm_model = generate_latent(hnorm, 10)
    hnorm_model_out = hnorm_model()
    @test length(hnorm_model_out) == 10
    @test typeof(hnorm_model_out) == Vector{Float64}

    fixed_model = fix(hnorm_model, (std = 0.1))

    n_samples = 100
    samples = sample(fixed_model, Prior(), n_samples; progress = false) |>
              chn -> mapreduce(vcat, generated_quantities(fixed_model, chn)) do gen
        gen
    end

    theoretical_mean = 0.2
    theoretical_var = 0.1^2

    @test isapprox(mean(samples), theoretical_mean, atol = 0.1)
    @test isapprox(var(samples), theoretical_var, atol = 0.2)

    ks_test_pval = ExactOneSampleKSTest(
        samples, Normal(theoretical_mean, sqrt(theoretical_var))) |> pvalue
    @test ks_test_pval > 1e-6
end
