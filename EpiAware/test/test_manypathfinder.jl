@testitem "ManyPathfinderMethod constructor" begin
    @testset "Default constructor" begin
        method = ManyPathfinderMethod()
        @test method.nruns == 4
        @test method.maxiters == 50
        @test method.max_tries == 100
    end

    @testset "Constructor" begin
        nruns = 5
        maxiters = 10
        max_tries = 10
        method = ManyPathfinderMethod(; nruns, maxiters, max_tries)
        @test method.nruns == nruns
        @test method.maxiters == maxiters
        @test method.max_tries == max_tries
    end
end
