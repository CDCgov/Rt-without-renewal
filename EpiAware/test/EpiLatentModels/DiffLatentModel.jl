@testitem "Testing DiffLatentModel constructor" begin
    using Distributions, Turing

    model = RandomWalk()
    @testset "Testing DiffLatentModel with vector of priors" begin
        init_priors = [Normal(0.0, 1.0), Normal(1.0, 2.0)]
        diff_model = DiffLatentModel(; model = model, init_priors = init_priors)

        @test diff_model.model == model
        @test diff_model.init_prior == arraydist(init_priors)
        @test diff_model.d == 2
        @test typeof(diff_model) <: AbstractTuringLatentModel
    end

    @testset "Testing DiffLatentModel with single prior and d" begin
        d = 3
        init_prior = Normal()
        diff_model = DiffLatentModel(model, init_prior; d = d)

        @test diff_model.model == model
        @test diff_model.init_prior == filldist(init_prior, d)
        @test diff_model.d == d
        @test typeof(diff_model) <: AbstractTuringLatentModel
    end
end

@testitem "Testing DiffLatentModel process" begin
    using DynamicPPL, Turing
    using Distributions
    using HypothesisTests: ExactOneSampleKSTest, pvalue

    n = 100
    d = 2
    model = RandomWalk(Normal(0.0, 1.0), truncated(Normal(0.0, 0.05), 0.0, Inf))
    init_priors = [Normal(0.0, 1.0), Normal(1.0, 2.0)]
    diff_model = DiffLatentModel(model = model, init_priors = init_priors)

    latent_model = generate_latent(diff_model, n)
    fixed_model = fix(
        latent_model, (σ_RW = 0, rw_init = 0.0))

    n_samples = 2000
    samples = sample(fixed_model, Prior(), n_samples; progress = false) |>
              chn -> mapreduce(hcat, generated_quantities(fixed_model, chn)) do gen
        gen[1]
    end

    #Because of the recursive d-times cumsum to undifference the process,
    #The distribution of the second day should be d lots of first day init distribution
    """
    Add two normal distributions `x` and `y` together.

    # Returns
    - `Normal`: The sum of `x` and `y` as a normal distribution.
    """
    function _add_normals(x::Normal, y::Normal)
        return Normal(x.μ + y.μ, sqrt(x.σ^2 + y.σ^2))
    end

    #Plus day two distribution
    day2_dist = _add_normals(
        Normal(d * init_priors[1].μ, d * init_priors[1].σ), init_priors[2])

    ks_test_pval_day1 = ExactOneSampleKSTest(samples[1, :], init_priors[1]) |> pvalue
    ks_test_pval_day2 = ExactOneSampleKSTest(samples[2, :], day2_dist) |> pvalue

    @test size(samples) == (n, n_samples)
    @test ks_test_pval_day1 > 1e-6 #Very unlikely to fail if the model is correctly implemented
    @test ks_test_pval_day2 > 1e-6 #Very unlikely to fail if the model is correctly implemented
end

@testitem "Testing DiffLatentModel runs with AR process" begin
    using DynamicPPL, Turing
    using Distributions

    n = 100
    d = 2
    model = AR()
    init_priors = [Normal(0.0, 1.0), Normal(1.0, 2.0)]
    diff_model = DiffLatentModel(model = model, init_priors = init_priors)

    latent_model = generate_latent(diff_model, n)
    fixed_model = fix(latent_model,
        (latent_init = [0.0, 1.0], σ_AR = 1.0, damp_AR = [0.8], ar_init = [0.0]))

    n_samples = 100
    samples = sample(fixed_model, Prior(), n_samples; progress = false) |>
              chn -> mapreduce(hcat, generated_quantities(fixed_model, chn)) do gen
        gen[1]
    end

    @test size(samples) == (n, n_samples)
end
