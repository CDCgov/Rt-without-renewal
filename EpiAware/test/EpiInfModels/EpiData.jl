
@testitem "EpiData constructor" begin
    gen_int = [0.2, 0.3, 0.5]
    transformation = exp

    data = EpiData(gen_int, transformation)

    @test length(data.gen_int) == 3
    @test data.len_gen_int == 3
    @test sum(data.gen_int) ≈ 1
    @test data.transformation(0.0) == 1.0
end

@testitem "EpiData constructor with distributions" begin
    using Distributions

    gen_distribution = Uniform(0.0, 10.0)
    cluster_coeff = 0.8
    time_horizon = 10
    D_gen = 10.0
    Δd = 1.0

    data = EpiData(; gen_distribution,
        D_gen = 10.0)

    @test data.len_gen_int == Int64(D_gen / Δd) - 1

    @test sum(data.gen_int) ≈ 1
end

@testitem "expected_Rt can correctly calculate Rt" begin
    gen_int = [0.2, 0.3, 0.5]
    transformation = exp

    data = EpiData(gen_int, transformation)

    infections = fill(10, 10)

    exp_Rt = expected_Rt(data, infections)

    @test all(exp_Rt .≈ 1.0)

    r = R_to_r(1.2, gen_int)
    infections = [10 * exp(r * i) for i in 1:10]
    exp_Rt = expected_Rt(data, infections)
    @test all(exp_Rt .|> x -> isapprox(x, 1.2, atol = 0.01))
end
