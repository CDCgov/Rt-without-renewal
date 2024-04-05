@testitem "NUTSampler constructor" begin
    using Turing
    @testset "Constructor" begin
        # Test the target acceptance rate
        @test_throws MethodError NUTSampler(2, Float64, MCMCSerial(), 1, 100)
        @test NUTSampler(ndraws = 100) isa NUTSampler
    end
end

@testitem "NUTSampler _apply_method" begin
    using Turing, Suppressor, HypothesisTests
    @model function test_mdl()
        x ~ Normal(0, 1)
    end
    nuts_method = NUTSampler(ndraws = 2_000)
    mdl = test_mdl()
    @suppress begin
        chn = apply_method(mdl, nuts_method)
        samples = chn[:x] |> vec
        ks_test_pval = ExactOneSampleKSTest(samples, Normal(0.0, 1)) |>
                       pvalue
        @test ks_test_pval > 1e-6
    end
end

@testitem "NUTSampler apply_method with Pathfinder initialisation" begin
    using Turing, Suppressor, HypothesisTests
    @model function test_mdl()
        x ~ Normal(0, 1)
    end
    ndraws = 2000
    nruns = 5
    maxiters = 10
    max_tries = 10

    pf_method = ManyPathfinder(ndraws, nruns, maxiters, max_tries)
    nuts_method = NUTSampler(ndraws = 2_000)
    mdl = test_mdl()

    @suppress begin
        best_pf = apply_method(mdl, pf_method)
        chn = apply_method(mdl, nuts_method, best_pf)
        samples = chn[:x] |> vec
        ks_test_pval = ExactOneSampleKSTest(samples, Normal(0.0, 1)) |>
                       pvalue
        @test ks_test_pval > 1e-6
    end
end
