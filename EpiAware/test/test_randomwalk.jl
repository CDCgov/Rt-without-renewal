
@testitem "Testing random_walk against theoretical properties" begin
    using DynamicPPL, Turing
    using HypothesisTests: ExactOneSampleKSTest, pvalue

    n = 5
    priors = default_rw_priors()
    rw_process = RandomWalk(Normal(0.0, 1.0),
        truncated(Normal(0.0, 0.05), 0.0, Inf))
    model = generate_latent(rw_process, n)
    fixed_model = fix(model, (σ_RW = 1.0, init_rw_value = 0.0)) #Fixing the standard deviation of the random walk process
    n_samples = 1000
    samples_day_5 = sample(fixed_model, Prior(), n_samples) |>
                    chn -> mapreduce(vcat, generated_quantities(fixed_model, chn)) do gen
        gen[1][5] #Extracting day 5 samples
    end
    #Check that the samples are drawn from the correct distribution which is Normal(mean = 0, var = 5)
    ks_test_pval = ExactOneSampleKSTest(samples_day_5, Normal(0.0, sqrt(5))) |> pvalue
    @test ks_test_pval > 1e-6 #Very unlikely to fail if the model is correctly implemented
end
@testitem "Testing default_rw_priors" begin
    @testset "var_RW_prior" begin
        priors = default_rw_priors()
        var_RW = rand(priors[:var_RW_prior])
        @test var_RW >= 0.0
    end

    @testset "init_rw_value_prior" begin
        priors = default_rw_priors()
        init_rw_value = rand(priors[:init_rw_value_prior])
        @test typeof(init_rw_value) == Float64
    end
end
@testset "Testing RandomWalk constructor" begin
    init_prior = Normal(0.0, 1.0)
    std_prior = truncated(Normal(0.0, 0.05), 0.0, Inf)
    rw_process = RandomWalk(init_prior, std_prior)
    @test rw_process.init_prior == init_prior
    @test rw_process.std_prior == std_prior
end
