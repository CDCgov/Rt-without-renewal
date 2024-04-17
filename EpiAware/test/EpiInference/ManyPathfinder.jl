@testitem "ManyPathfinder constructor" begin
    @testset "Default constructor" begin
        method = ManyPathfinder()
        @test method.ndraws == 10
        @test method.nruns == 4
        @test method.maxiters == 100
        @test method.max_tries == 100
    end

    @testset "Constructor" begin
        nruns = 5
        maxiters = 10
        max_tries = 10
        method = ManyPathfinder(; nruns, maxiters, max_tries)
        @test method.nruns == nruns
        @test method.maxiters == maxiters
        @test method.max_tries == max_tries
    end
end

@testitem "Test case: check _apply_method" begin
    using Turing, Suppressor, HypothesisTests

    @model function basic_normal()
        x ~ Normal(0, 1)
    end

    mdl = basic_normal()

    ndraws = 2000
    nruns = 5
    maxiters = 10
    max_tries = 10
    method = ManyPathfinder(; ndraws, nruns, maxiters, max_tries)

    #Test that does good job finding simple distribution
    @suppress begin
        best_pf = _apply_method(mdl, method)
        pathfinder_samples = best_pf.draws |> vec
        ks_test_pval = ExactOneSampleKSTest(pathfinder_samples, Normal(0.0, 1)) |>
                       pvalue
        @test ks_test_pval > 1e-6
    end
end
