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
        gen[5] #Extracting day 5 samples
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

@testitem "Testing RandomWalk parameter recovery: Negative Binomial errors on log rw" begin
    using Random, Turing, FillArrays, Distributions, LinearAlgebra, DynamicPPL, StatsBase,
          ReverseDiff
    Random.seed!(1234)

    rw_process = RandomWalk()
    obs_nb = PoissonError()

    @model function test_poisson_errors(rw, obs, y_t)
        n = length(y_t)
        @submodel Z_t = generate_latent(rw, n)
        @submodel y_t = generate_observations(obs, y_t, exp.(Z_t))
        return Z_t, y_t
    end

    generative_mdl = test_poisson_errors(rw_process, obs_nb, fill(missing, 40))
    θ_true = rand(generative_mdl)
    Z_t_obs, y_t_obs = condition(generative_mdl, θ_true)()

    mdl = test_poisson_errors(rw_process, obs_nb, Int.(y_t_obs))
    chn = sample(
        mdl, NUTS(adtype = AutoReverseDiff(; compile = Val(true))), 1000; progess = false)

    #Check that are in central 99.9% of the posterior predictive distribution
    #Therefore, this should be unlikely to fail if the model is correctly implemented
    @testset "Check true parameters are within 99.9% central post. prob.: " begin
        params_to_check = keys(θ_true)
        @testset for param in params_to_check
            if param ∈ keys(chn)
                posterior_p = ecdf(chn[param][:])(θ_true[param])
                @test 0.0005 < posterior_p < 0.9995
            end
        end
    end
end
