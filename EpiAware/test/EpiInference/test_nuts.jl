@testitem "NUTSampler Tests" begin
    using Turing, Suppressor, HypothesisTests
    # Test the construction of NUTSampler
    @testset "Constructor" begin
        # Test the target acceptance rate
        @test_throws MethodError NUTSampler(2, Float64, MCMCSerial(), 1, 100)
        @test NUTSampler(ndraws = 100) isa NUTSampler
    end
    # Test _apply_method function
    @testset "_apply_method" begin
        @model function test_mdl()
            x ~ Normal(0, 1)
        end
        nuts_method = NUTSampler(ndraws = 2_000)
        mdl = test_mdl()
        @suppress begin
            chn = _apply_method(nuts_method, mdl)
            samples = chn[:x] |> vec
            ks_test_pval = ExactOneSampleKSTest(samples, Normal(0.0, 1)) |>
                           pvalue
            @test ks_test_pval > 1e-6
        end
    end
    # Test _apply_method function with pathfinder initialisation
    @testset "_apply_method with PF initialisation" begin
        @model function test_mdl()
            x ~ Normal(0, 1)
        end
        ndraws = 2000
        nruns = 5
        maxiters = 10
        max_tries = 10

        pf_method = ManyPathfinder(; ndraws, nruns, maxiters, max_tries)
        nuts_method = NUTSampler(ndraws = 2_000)
        mdl = test_mdl()

        @suppress begin
            best_pf = _apply_method(pf_method, mdl)
            chn = _apply_method(nuts_method, mdl, best_pf)
            samples = chn[:x] |> vec
            ks_test_pval = ExactOneSampleKSTest(samples, Normal(0.0, 1)) |>
                           pvalue
            @test ks_test_pval > 1e-6
        end
    end
end
