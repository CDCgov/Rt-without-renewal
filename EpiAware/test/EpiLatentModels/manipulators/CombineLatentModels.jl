@testitem "CombineLatentModels constructor works as expected" begin
    using Distributions: Normal
    int = Intercept(Normal(0, 1))
    ar = AR()
    prefix_int = PrefixLatentModel(int, "Combine.1")
    prefix_ar = PrefixLatentModel(ar, "Combine.2")
    comb = CombineLatentModels([int, ar])
    @test typeof(comb) <: AbstractTuringLatentModel
    @test comb.models == [prefix_int, prefix_ar]
    @test comb.prefixes == ["Combine.1", "Combine.2"]

    comb = CombineLatentModels([int, ar], ["Int", "AR"])
    prefix_int = PrefixLatentModel(int, "Int")
    prefix_ar = PrefixLatentModel(ar, "AR")
    @test comb.models == [prefix_int, prefix_ar]
    @test comb.prefixes == ["Int", "AR"]
end

@testitem "CombineLatentModels constructor handles duplicate models" begin
    using Distributions: Normal
    comb = CombineLatentModels([Intercept(Normal(0, 1)), Intercept(Normal(0, 2))])
    prefix_1 = PrefixLatentModel(Intercept(Normal(0, 1)), "Combine.1")
    prefix_2 = PrefixLatentModel(Intercept(Normal(0, 2)), "Combine.2")

    @test typeof(comb) <: AbstractTuringLatentModel
    @test comb.models == [prefix_1, prefix_2]
    @test comb.prefixes == ["Combine.1", "Combine.2"]
end

@testitem "CombineLatentModels generate_latent method works as expected: FixedIntecept + custom" begin
    using Turing

    struct NextScale <: AbstractTuringLatentModel end

    @model function EpiAware.EpiAwareBase.generate_latent(model::NextScale, n::Int)
        scale = 2
        return fill(scale, n)
    end

    s = FixedIntercept(1)
    ns = NextScale()
    comb = CombineLatentModels([s, ns])
    comb_model = generate_latent(comb, 5)
    comb_model_out = comb_model()

    @test typeof(comb_model) <: DynamicPPL.Model
    @test length(comb_model_out) == 5
    @test all(comb_model_out .== fill(3.0, 5))
end

@testitem "CombineLatentModels generate_latent method works as expected: Intercept + AR" begin
    using Turing
    using Distributions
    using HypothesisTests: ExactOneSampleKSTest, pvalue
    using LinearAlgebra: Diagonal

    int = Intercept(Normal(0, 1))
    ar = AR()
    n = 10
    comb = CombineLatentModels([int, ar])
    comb_model = generate_latent(comb, n)

    # Test constant if conditioning on zero residuals
    no_residual_mdl = comb_model |
                      (var"Combine.2.ϵ_t" = zeros(n - 1), var"Combine.2.ar_init" = [0.0])
    y_const = no_residual_mdl()

    @test all(y_const .== y_const[1])

    # Check against linear regression by conditioning on normal residuals
    # Generate data
    fix_intercept = 0.5
    normal_res_mdl = comb_model |
                     (var"Combine.2.damp_AR" = [0.0], var"Combine.2.σ_AR" = 1.0,
        var"Combine.1.intercept" = fix_intercept)
    y = normal_res_mdl()

    # Fit no-slope linear regression as a model test
    @model function no_slope_linear_regression(y)
        @submodel y_pred = generate_latent(comb, n)
        y ~ MvNormal(y_pred, Diagonal(ones(n)))
    end

    ns_regression_mdl = no_slope_linear_regression(y) |
                        (var"Combine.2.damp_AR" = [0.0], var"Combine.2.σ_AR" = 1.0,
        var"Combine.2.ϵ_t" = zeros(n - 1), var"Combine.2.ar_init" = [0.0])
    chain = sample(ns_regression_mdl, NUTS(), 5000; progress = false)

    # Theoretical posterior distribution for intercept
    # if \beta ~ int.intercept_prior = N(\mu_0, \sigma_0) and \sigma^2 = 1 for
    #    the white noise
    # then the posterior distribution for the intercept is Normal
    # \mathcal{N}(\text{mean} = (n * \sigma_0^2 * ȳ + \mu_0) / (n * \sigma_0^2 + 1),
    #             \text{var} = \sigma_0^2 / (n * \sigma_0^2 + 1))

    post_mean = (n * var(int.intercept_prior) * mean(y) + mean(int.intercept_prior)) /
                (n * var(int.intercept_prior) + 1)
    post_var = var(int.intercept_prior) / (n * var(int.intercept_prior) + 1)
    post_dist = Normal(post_mean, sqrt(post_var))

    samples = get(chain, :var"Combine.1.intercept").var"Combine.1.intercept" |> vec
    ks_test_pval = ExactOneSampleKSTest(samples, post_dist) |> pvalue
    @test ks_test_pval > 1e-6
end
