@testitem "Testing _run_manypathfinder function" begin
    using Turing, Pathfinder

    @testset "Test case: check runs" begin
        @model function test_model()
            x ~ Normal(0, 1)
            y ~ Normal(x, 1)
        end

        mdl = test_model()

        nruns = 10
        ndraws = 100
        maxiters = 50

        pfs = EpiAware.InferenceMethods._run_manypathfinder(
            mdl; nruns = nruns, ndraws = ndraws, maxiters = maxiters)

        @test length(pfs) == nruns
        @test all(p -> p isa Union{PathfinderResult, Symbol}, pfs)
    end
    @testset "Test case: check fail mode for bad model" begin
        @model function bad_model()
            x ~ Normal(0, 1)
            return sqrt(x) #<-fails
        end
        badmdl = bad_model()
        nruns = 5
        ndraws = 50
        maxiters = 100

        pfs = EpiAware.InferenceMethods._run_manypathfinder(
            badmdl; nruns = nruns, ndraws = ndraws, maxiters = maxiters)

        @test all(pfs .== :fail)
    end
end
@testitem "Testing _continue_manypathfinder! function" begin
    using Turing, Pathfinder

    @testset "Check that it only adds one more for easy model" begin
        @model function easy_model()
            x ~ Normal(0, 1)
        end

        easymdl = easy_model()

        pfs = Vector{Union{PathfinderResult, Symbol}}([:fail, :fail, :fail])
        max_tries = 3
        nruns = 10
        ndraws = 100
        maxiters = 50

        pfs = EpiAware.InferenceMethods._continue_manypathfinder!(
            pfs, easymdl; max_tries, nruns, ndraws, maxiters)

        @test pfs[end] isa PathfinderResult
    end

    @testset "Check always fails for bad models and throws correct Exception" begin
        @model function bad_model()
            x ~ Normal(0, 1)
            return sqrt(x) #<-fails
        end
        badmdl = bad_model()

        pfs = Vector{Union{PathfinderResult, Symbol}}([:fail, :fail, :fail])
        max_tries = 3
        nruns = 10
        ndraws = 100
        maxiters = 50

        @test_throws "All pathfinder runs failed after $max_tries tries." begin
            pfs = EpiAware.InferenceMethods._continue_manypathfinder!(
                pfs, badmdl; max_tries, nruns, ndraws, maxiters)
        end
    end
end
@testitem "Testing _get_best_elbo_pathfinder function" begin
    using Pathfinder, Turing

    @model function test_model()
        x ~ Normal(0, 1)
        y ~ Normal(x, 1)
    end

    mdl = test_model()
    nruns = 10
    ndraws = 100
    maxiters = 50

    pfs = EpiAware.InferenceMethods._run_manypathfinder(
        mdl; nruns = nruns, ndraws = ndraws, maxiters = maxiters)

    best_pf = EpiAware.InferenceMethods._get_best_elbo_pathfinder(pfs)
    @test best_pf isa PathfinderResult
end
@testitem "Testing manypathfinder function" begin
    using Turing, Pathfinder, HypothesisTests
    @testset "Test model works" begin
        @model function test_model()
            x ~ Normal(0, 1)
            y ~ Normal(x, 1)
        end

        mdl = test_model()

        nruns = 4
        ndraws = 10
        nchains = 4
        maxiters = 50
        max_tries = 100

        best_pf = manypathfinder(mdl, ndraws; nruns = nruns,
            maxiters = maxiters, max_tries = max_tries)

        @test best_pf isa PathfinderResult
    end

    @testset "Does good job finding simple distribution" begin
        @model function basic_normal()
            x ~ Normal(0, 1)
        end
        mdl = basic_normal()
        nruns = 4
        ndraws = 2000
        nchains = 4
        maxiters = 50
        max_tries = 10

        best_pf = manypathfinder(mdl, ndraws; nruns = nruns,
            maxiters = maxiters, max_tries = max_tries)

        pathfinder_samples = best_pf.draws |> vec
        ks_test_pval = ExactOneSampleKSTest(pathfinder_samples, Normal(0.0, 1)) |> pvalue
        @test ks_test_pval > 1e-6
    end

    @testset "Check always fails for bad models and throws correct Exception" begin
        @model function bad_model()
            x ~ Normal(0, 1)
            return sqrt(x) #<-fails
        end
        badmdl = bad_model()

        max_tries = 3
        nruns = 10
        ndraws = 100
        maxiters = 50
        nchains = 4

        @test_throws "All pathfinder runs failed after $max_tries tries." begin
            manypathfinder(badmdl, ndraws; nruns = nruns, nchains = nchains,
                maxiters = maxiters, max_tries = max_tries)
        end
    end
end
