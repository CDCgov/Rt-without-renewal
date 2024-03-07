@testitem "Testing _run_manypathfinder function" begin
    using Turing, Pathfinder
    @model function test_model()
        x ~ Normal(0, 1)
        y ~ Normal(x, 1)
    end

    mdl = test_model()

    # Test case 1
    @testset "Test case 1" begin
        nruns = 10
        ndraws = 100
        maxiters = 50

        pfs = EpiAware._run_manypathfinder(
            mdl; nruns = nruns, ndraws = ndraws, maxiters = maxiters)

        @test length(pfs) == nruns
        @test all(p -> p isa Union{PathfinderResult, Symbol}, pfs)
    end

    # Test case 2
    @testset "Test case 2" begin
        nruns = 5
        ndraws = 50
        maxiters = 100

        pfs = EpiAware._run_manypathfinder(
            mdl; nruns = nruns, ndraws = ndraws, maxiters = maxiters)

        @test length(pfs) == nruns
        @test all(p -> p isa Union{PathfinderResult, Symbol}, pfs)
    end
end
@testitem "Testing _continue_manypathfinder! function" begin
    using Turing, Pathfinder

    @testset "Test case 1" begin
        @model function test_model()
            x ~ Normal(0, 1)
            y ~ Normal(x, 1)
        end

        mdl = test_model()

        pfs = Vector{Union{PathfinderResult, Symbol}}([:fail, :fail, :fail])
        max_tries = 3
        nruns = 10
        ndraws = 100
        maxiters = 50

        pfs = EpiAware._continue_manypathfinder!(
            pfs, mdl; max_tries, nruns, ndraws, maxiters)

        @test all(p -> p isa Union{PathfinderResult, Symbol}, pfs)
    end

    @testset "Test case 2" begin
        @model function test_model()
            x ~ Normal(0, 1)
            y ~ Normal(x, 1)
        end

        mdl = test_model()

        pfs = Vector{Union{PathfinderResult, Symbol}}([:fail, :fail, :fail])
        max_tries = 3
        nruns = 10
        ndraws = 100
        maxiters = 50

        pfs = EpiAware._continue_manypathfinder!(
            pfs, mdl; max_tries, nruns, ndraws, maxiters)

        @test all(p -> p isa Union{PathfinderResult, Symbol}, pfs)
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

    pfs = EpiAware._run_manypathfinder(
        mdl; nruns = nruns, ndraws = ndraws, maxiters = maxiters)

    best_pf = EpiAware._get_best_elbo_pathfinder(pfs)
    @test best_pf isa PathfinderResult
end
@testitem "Testing manypathfinder function" begin
    using Turing, Pathfinder

    @model function test_model()
        x ~ Normal(0, 1)
        y ~ Normal(x, 1)
    end

    mdl = test_model()

    # Test case 1
    @testset "Test case 1" begin
        nruns = 4
        ndraws = 10
        nchains = 4
        maxiters = 50
        max_tries = 100

        best_pf = manypathfinder(mdl; nruns = nruns, ndraws = ndraws, nchains = nchains,
            maxiters = maxiters, max_tries = max_tries)

        @test best_pf isa PathfinderResult
    end

    # Test case 2
    @testset "Test case 2" begin
        nruns = 2
        ndraws = 5
        nchains = 2
        maxiters = 30
        max_tries = 50

        best_pf = manypathfinder(mdl; nruns = nruns, ndraws = ndraws, nchains = nchains,
            maxiters = maxiters, max_tries = max_tries)

        @test best_pf isa PathfinderResult
    end
end
