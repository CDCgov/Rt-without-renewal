
@testset "EpiModel constructor" begin
    gen_int = [0.2, 0.3, 0.5]
    delay_int = [0.1, 0.4, 0.5]
    cluster_coeff = 0.8
    time_horizon = 10

    model = EpiModel(gen_int, delay_int, cluster_coeff, time_horizon)

    @test length(model.gen_int) == 3
    @test length(model.delay_int) == 3
    @test model.cluster_coeff == 0.8
    @test model.len_gen_int == 3
    @test model.len_delay_int == 3

    @test sum(model.gen_int) ≈ 1
    @test sum(model.delay_int) ≈ 1

    @test size(model.delay_kernel) == (time_horizon, time_horizon)
end

@testset "EpiModel constructor" begin
    gen_int = [0.2, 0.3, 0.5]
    delay_int = [0.1, 0.4, 0.5]
    cluster_coeff = 0.8
    time_horizon = 10

    model = EpiModel(gen_int, delay_int, cluster_coeff, time_horizon)

    @test length(model.gen_int) == 3
    @test length(model.delay_int) == 3
    @test model.cluster_coeff == 0.8
    @test model.len_gen_int == 3
    @test model.len_delay_int == 3

    @test sum(model.gen_int) ≈ 1
    @test sum(model.delay_int) ≈ 1

    @test size(model.delay_kernel) == (time_horizon, time_horizon)
end

@testset "EpiModel function" begin
    recent_incidence = [10, 20, 30]
    Rt = 1.5

    expected_new_incidence = Rt * dot(recent_incidence, [0.2, 0.3, 0.5])
    expected_output =
        [expected_new_incidence; recent_incidence[1:2]], expected_new_incidence

    model = EpiModel([0.2, 0.3, 0.5], [0.1, 0.4, 0.5], 0.8, 10)

    @test model(recent_incidence, Rt) == expected_output
end
@testset "EpiModel constructor" begin
    gen_int = [0.2, 0.3, 0.5]
    delay_int = [0.1, 0.4, 0.5]
    cluster_coeff = 0.8
    time_horizon = 10

    model = EpiModel(gen_int, delay_int, cluster_coeff, time_horizon)

    @test length(model.gen_int) == 3
    @test length(model.delay_int) == 3
    @test model.cluster_coeff == 0.8
    @test model.len_gen_int == 3
    @test model.len_delay_int == 3

    @test sum(model.gen_int) ≈ 1
    @test sum(model.delay_int) ≈ 1

    @test size(model.delay_kernel) == (time_horizon, time_horizon)
end

@testset "EpiModel function" begin
    recent_incidence = [10, 20, 30]
    Rt = 1.5

    expected_new_incidence = Rt * dot(recent_incidence, [0.2, 0.3, 0.5])
    expected_output =
        [expected_new_incidence; recent_incidence[1:2]], expected_new_incidence

    model = EpiModel([0.2, 0.3, 0.5], [0.1, 0.4, 0.5], 0.8, 10)

    @test model(recent_incidence, Rt) == expected_output
end

@testset "EpiModel constructor with distributions" begin
    using Distributions

    gen_distribution = Uniform(0.0, 10.0)
    delay_distribution = Exponential(1.0)
    cluster_coeff = 0.8
    time_horizon = 10
    D_gen = 10.0
    D_delay = 10.0
    Δd = 1.0

    model = EpiModel(
        gen_distribution,
        delay_distribution,
        cluster_coeff,
        time_horizon;
        D_gen = 10.0,
        D_delay = 10.0,
    )

    @test model.cluster_coeff == 0.8
    @test model.len_gen_int == Int64(D_gen / Δd) - 1
    @test model.len_delay_int == Int64(D_delay / Δd)

    @test sum(model.gen_int) ≈ 1
    @test sum(model.delay_int) ≈ 1

    @test size(model.delay_kernel) == (time_horizon, time_horizon)
end
