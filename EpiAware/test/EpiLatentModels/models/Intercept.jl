@testitem "Intercept constructor works as expected" begin
    using Distributions: Normal
    int = Intercept(Normal(0, 1))
    @test typeof(int) <: AbstractTuringLatentModel
    @test int.intercept_prior == Normal(0, 1)
end

@testitem "Intercept generate_latent method works as expected" begin
    using Turing
    using Distributions: Normal
    using HypothesisTests: ExactOneSampleKSTest, pvalue
    int = Intercept(Normal(0.1, 1))
    int_model = generate_latent(int, 10)
    int_model_out = int_model()
    @test length(int_model_out) == 10
    @test all(x -> x == int_model_out[1], int_model_out)

    int_samples = sample(int_model, Prior(), 1000; progress = false) |>
                  chn -> get(chn, :intercept).intercept |>
                         vec

    ks_test_pval = ExactOneSampleKSTest(int_samples, Normal(0.1, 1)) |> pvalue
    @test ks_test_pval > 1e-6
end
