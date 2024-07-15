@testitem "Testing random_walk against theoretical properties" begin
    using DynamicPPL, Turing
    using HypothesisTests: ExactOneSampleKSTest, pvalue

    n = 5
    rw_process = RandomWalk(Normal(0.0, 1.0), HalfNormal(0.05))
    model = generate_latent(rw_process, n)
    fixed_model = fix(model, (σ_RW = 1.0, init_rw_value = 0.0)) #Fixing the standard deviation of the random walk process
    n_samples = 1000
    samples_day_5 = sample(fixed_model, Prior(), n_samples; progress = false) |>
                    chn -> mapreduce(vcat, generated_quantities(fixed_model, chn)) do gen
        gen[1][5] #Extracting day 5 samples
    end
    #Check that the samples are drawn from the correct distribution which is Normal(mean = 0, var = 5)
    ks_test_pval = ExactOneSampleKSTest(samples_day_5, Normal(0.0, sqrt(5))) |> pvalue
    @test ks_test_pval > 1e-6 #Very unlikely to fail if the model is correctly implemented
end

@testitem "Testing default RW priors" begin
    @testset "std_prior" begin
        priors = RandomWalk()
        std_rw = rand(priors.std_prior)
        @test std_rw >= 0.0
    end

    @testset "init_prior" begin
        priors = RandomWalk()
        init_value = rand(priors.init_prior)
        @test typeof(init_value) == Float64
    end
end

@testitem "Testing RandomWalk constructor" begin
    using Distributions: Normal, truncated
    init_prior = Normal(0.0, 1.0)
    std_prior = HalfNormal(0.05)
    rw_process = RandomWalk(init_prior, std_prior)
    @test rw_process.init_prior == init_prior
    @test rw_process.std_prior == std_prior
end

@testitem "Testing RandomWalk parameter recovery: Normal errors" begin
    using Random, Turing, FillArrays, Distributions, LinearAlgebra, DynamicPPL, StatsBase
    Random.seed!(1234)

    rw_process = RandomWalk()

    @model function test_normal_errors(rw, Z_obs, σ_obs_prior)
        n = ismissing(Z_obs) ? 40 : length(Z_obs)
        σ ~ σ_obs_prior
        @submodel Z_t, _ = generate_latent(rw, n)
        Z_obs ~ MvNormal(Z_t, Diagonal(Fill(σ, n)))
        return Z_t
    end

    Z_generated = rand(test_normal_errors(rw_process, missing, HalfNormal(0.05)))
    mdl = test_normal_errors(rw_process, Z_generated.Z_obs, HalfNormal(0.05))
    chn = sample(mdl, NUTS(), 1000)

    #Posterior predictive p values for the standard deviations
    #Check that are in central 99% of the posterior predictive distribution
    posterior_p_σ = ecdf(chn[:σ][:])(Z_generated.σ)
    posterior_p_σ_RW = ecdf(chn[:σ_RW][:])(Z_generated.σ_RW)

    @test 0.005 < posterior_p_σ < 0.9995
    @test 0.005 < posterior_p_σ_RW < 0.9995
end

@testitem "Testing RandomWalk parameter recovery: Negative Binomial errors" begin
    using Random, Turing, FillArrays, Distributions, LinearAlgebra, DynamicPPL, StatsBase
    Random.seed!(1234)

    rw_process = RandomWalk()

    @model function test_normal_errors(rw, Z_obs, σ_obs_prior)
        n = ismissing(Z_obs) ? 40 : length(Z_obs)
        σ ~ σ_obs_prior
        @submodel Z_t, _ = generate_latent(rw, n)
        Z_obs ~ MvNormal(Z_t, Diagonal(Fill(σ, n)))
        return Z_t
    end

    Z_generated = rand(test_normal_errors(rw_process, missing, HalfNormal(0.05)))
    mdl = test_normal_errors(rw_process, Z_generated.Z_obs, HalfNormal(0.05))
    chn = sample(mdl, NUTS(), 1000, progess = false)

    #Posterior predictive p values for the standard deviations
    #Check that are in central 99% of the posterior predictive distribution
    posterior_p_σ = ecdf(chn[:σ][:])(Z_generated.σ)
    posterior_p_σ_RW = ecdf(chn[:σ_RW][:])(Z_generated.σ_RW)
    posterior_p_rinit = ecdf(chn[:rw_init][:])(Z_generated.rw_init)

    @test 0.005 < posterior_p_σ < 0.9995
    @test 0.005 < posterior_p_σ_RW < 0.9995
    @test 0.005 < posterior_p_rinit < 0.9995
end

@testitem "Testing RandomWalk parameter recovery: Negative Binomial errors on log rw" begin
    using Random, Turing, FillArrays, Distributions, LinearAlgebra, DynamicPPL, StatsBase
    Random.seed!(1234)

    rw_process = RandomWalk()
    obs_nb = NegativeBinomialError()

    @model function test_negbin_errors(rw, obs, y_t)
        n = ismissing(y_t) ? 40 : length(y_t)
        @submodel Z_t, _ = generate_latent(rw, n)
        @submodel y_t, _ = generate_observations(obs, y_t, exp.(Z_t))
        return Z_t, y_t
    end

    gen_mdl = test_negbin_errors(rw_process, obs_nb, missing)
    obs_rand = rand(gen_mdl)
    Z_t_obs, y_t_obs = condition(gen_mdl, obs_rand)()

    mdl = test_negbin_errors(rw_process, obs_nb, y_t_obs)
    chn = sample(mdl, NUTS(), 1000, progess = false)

    #Posterior predictive p values for singleton parameters
    #Check that are in central 99% of the posterior predictive distribution
    posterior_p_σ_RW = ecdf(chn[:σ_RW][:])(obs_rand.σ_RW)
    posterior_p_cf = ecdf(chn[:cluster_factor][:])(obs_rand.cluster_factor)
    posterior_p_rinit = ecdf(chn[:rw_init][:])(obs_rand.rw_init)

    @test 0.005 < posterior_p_cf < 0.9995
    @test 0.005 < posterior_p_σ_RW < 0.9995
    @test 0.005 < posterior_p_rinit < 0.9995
end
