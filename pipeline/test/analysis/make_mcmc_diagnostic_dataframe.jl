@testset "test MCMC convergence analysis on toy obs model" begin
    using JLD2, DataFramesMeta, Turing, EpiAware
    # Reuse the local config
    _output = load(joinpath(@__DIR__(), "test_data.jld2"))
    inference_config = _output["inference_config"]
    # Create a simple test model to test mcmc diagnostics via prior sampling
    obs = make_observation_model(SmoothEndemicPipeline())
    @model function test_model()
        x ~ filldist(Normal(0, 1), 20)
        @submodel prefix="obs" y_t=generate_observations(obs, missing, exp.(x))
    end
    n = 1000
    samples = sample(test_model(), Prior(), n)

    # Create a simple output to test the function
    output = Dict(
        "inference_config" => inference_config,
        "inference_results" => (; samples,)
    )

    true_mean_gi = 10.0
    scenario = "rough_endemic"
    df = make_mcmc_diagnostic_dataframe(
        output, true_mean_gi, "rough_endemic")
    # Check pass throughs
    @test typeof(df) == DataFrame
    @test size(df, 1) == 3  # Number of rows should match the length of used_gi_means
    @test df[1, :Scenario] == scenario
    @test df[1, :latent_model] == inference_config["latent_model"]
    @test df[1, :True_GI_Mean] == true_mean_gi
    # Prior sampling should be uncorrelated and meet all the convergence criteria
    @test all(df[:, :ess_bulk_prop_pass] .== 1.0)
    @test all(df[:, :ess_tail_prop_pass] .== 1.0)
    @test all(df[:, :rhat_diff_prop_pass] .== 1.0)
    @test all(df[:, :has_cluster_factor] .== true)
    @test all(df[1, :cluster_factor_tail] .> n / 2)
end
