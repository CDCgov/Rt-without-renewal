@testset "test plot_truth_data" begin
    using CairoMakie
    #Toy data
    y_t = rand(1:100, 28)
    I_t = randn(28) .+ 50
    data = Dict("y_t" => y_t, "I_t" => I_t)
    config = Dict("truth_gi_mean" => 1.5)
    subdirname = "test"
    testpipeline = RtwithoutRenewalPriorPipeline()

    f, path = plot_truth_data(
        data, config, testpipeline; plotsubdir = subdirname, saveplot = false)
    @test f isa Figure
    @test path isa String
    @test (splitdir ∘ dirname)(path)[end] == subdirname
end

@testset "test plot_Rt" begin
    using CairoMakie
    #Toy data
    R_t = randn(100) |> cumsum .|> exp
    config = Dict("truth_gi_mean" => 1.5)
    subdirname = "test"
    testpipeline = RtwithoutRenewalPriorPipeline()

    f, path = plot_Rt(R_t, config, testpipeline; plotsubdir = subdirname, saveplot = false)
    @test f isa Figure
    @test path isa String
    @test (splitdir ∘ dirname)(path)[end] == subdirname
end
