@testset "default_gi_params: returns a dictionary with correct keys" begin
    using .AnalysisPipeline

    params = default_gi_params()
    @test params isa Dict
    @test haskey(params, "gi_means")
    @test haskey(params, "gi_stds")
end

@testset "default_Rt: returns an array" begin
    using .AnalysisPipeline

    Rt = default_Rt()
    @test Rt isa Array
end

@testset "default_tspan: returns an Tuple{Integer, Integer}" begin
    using .AnalysisPipeline

    tspan = default_tspan()
    @test tspan isa Tuple{Integer, Integer}
end
