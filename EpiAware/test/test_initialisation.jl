using DynamicPPL: generate_tilde_assume
@testitem "Initialisation Tests" begin
    using Distributions
    mean_init = 10.0
    init_mdl = EpiAware.SimpleInitialisation(
        Normal(mean_init, 1.0), truncated(Normal(0.0, 0.05), 0.0, Inf))
    @test mean(init_mdl.mean_I0_prior) == 10.0
end

@testitem "generate_initialisation default" begin
    struct TestInitialisation <: EpiAware.AbstractInitialisation end
    @test isnothing(EpiAware.generate_initialisation(TestInitialisation()))
end

@testitem "generate_initialisation Test" begin
    using Distributions, DynamicPPL, Turing, HypothesisTests
    mean_init = 10.0
    init = EpiAware.SimpleInitialisation(
        Normal(mean_init, 1.0), truncated(Normal(0.0, 0.05), 0.0, Inf))

    init_mdl = EpiAware.generate_initialisation(init)
    fix_init_mdl = fix(init_mdl, (μ_I0 = 10.0, σ²_I0 = 1.0))

    n_samples = 2000
    smpls = sample(fix_init_mdl, Prior(), n_samples) |>
            chn -> generated_quantities(fix_init_mdl, chn) .|>
                   (gen -> gen[1]) |>
                   vec

    ks_test_pval = ExactOneSampleKSTest(smpls, Normal(10.0, 1.0)) |> pvalue
    @test ks_test_pval > 1e-6 #Very unlikely to fail if the model is correctly implemented
end
