@testitem "Testing default_diff_latent_priors" begin
    using Distributions

    d = 3
    priors = EpiAware.default_diff_latent_priors(d)

    @test length(priors[:init_prior]) == d
    for prior in priors[:init_prior]
        @test prior isa Normal
        @test prior.μ == 0.0
        @test prior.σ == 1.0
    end
end

@testitem "Testing DiffLatentModel constructor" begin
    using Distributions

    model = EpiAware.RandomWalk(Normal(0.0, 1.0), truncated(Normal(0.0, 0.05), 0.0, Inf))
    init_prior = [Normal(0.0, 1.0), Normal(1.0, 2.0)]
    diff_model = EpiAware.DiffLatentModel(model, init_prior)

    @test diff_model.model == model
    @test diff_model.init_prior == init_prior
    @test diff_model.d == 2
end

@testitem "Testing DiffLatentModel process" begin
    using DynamicPPL, Turing
    using Distributions

    n = 100
    d = 2
    model = EpiAware.RandomWalk(Normal(0.0, 1.0), truncated(Normal(0.0, 0.05), 0.0, Inf))
    init_prior = [Normal(0.0, 1.0), Normal(1.0, 2.0)]
    diff_model = EpiAware.DiffLatentModel(model, init_prior)

    latent_model = EpiAware.generate_latent(diff_model, n)
    fixed_model = fix(
        latent_model, (latent_init = [0.0, 1.0], σ²_RW = 1.0, init_rw_value = 0.0))

    n_samples = 100
    samples = sample(fixed_model, Prior(), n_samples) |>
              chn -> mapreduce(vcat, generated_quantities(fixed_model, chn)) do gen
        gen[1]
    end

    @test size(samples) == (n, n_samples)
    @test all(samples[1, :] .≈ 0.0)
    @test all(samples[2, :] .≈ 1.0)
    @test all(samples[3, :] .≈ samples[2, :] .+ samples[1, :])
end

@testitem "Testing DiffLatentModel with AR process" begin
    using DynamicPPL, Turing
    using Distributions

    n = 100
    d = 2
    model = EpiAware.AR(EpiAware.default_ar_priors()[:damp_prior],
        EpiAware.default_ar_priors()[:var_prior],
        EpiAware.default_ar_priors()[:init_prior])
    init_prior = [Normal(0.0, 1.0), Normal(1.0, 2.0)]
    diff_model = EpiAware.DiffLatentModel(model, init_prior)

    latent_model = EpiAware.generate_latent(diff_model, n)
    fixed_model = fix(latent_model,
        (latant_init = [0.0, 1.0], σ²_AR = 1.0, damp_AR = [0.8], ar_init = [0.0]))

    n_samples = 100
    samples = sample(fixed_model, Prior(), n_samples) |>
              chn -> mapreduce(vcat, generated_quantities(fixed_model, chn)) do gen
        gen[1]
    end

    @test size(samples) == (n, n_samples)
    @test all(samples[1, :] .≈ 0.0)
    @test all(samples[2, :] .≈ 1.0)
    @test all(samples[3, :] .≈ samples[2, :] .+ samples[1, :])
end
