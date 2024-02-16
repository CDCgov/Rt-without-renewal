
@testitem "EpiData constructor" begin
    gen_int = [0.2, 0.3, 0.5]
    delay_int = [0.1, 0.4, 0.5]
    cluster_coeff = 0.8
    time_horizon = 10
    transformation = exp

    data = EpiData(gen_int, delay_int, cluster_coeff, time_horizon, transformation)

    @test length(data.gen_int) == 3
    @test length(data.delay_int) == 3
    @test data.cluster_coeff == 0.8
    @test data.len_gen_int == 3
    @test data.len_delay_int == 3

    @test sum(data.gen_int) ≈ 1
    @test sum(data.delay_int) ≈ 1

    @test size(data.delay_kernel) == (time_horizon, time_horizon)
    @test data.transformation(0.0) == 1.0
end

@testitem "EpiData constructor with distributions" begin
    using Distributions

    gen_distribution = Uniform(0.0, 10.0)
    delay_distribution = Exponential(1.0)
    cluster_coeff = 0.8
    time_horizon = 10
    D_gen = 10.0
    D_delay = 10.0
    Δd = 1.0

    data = EpiData(
        gen_distribution,
        delay_distribution,
        cluster_coeff,
        time_horizon;
        D_gen = 10.0,
        D_delay = 10.0,
    )

    @test data.cluster_coeff == 0.8
    @test data.len_gen_int == Int64(D_gen / Δd) - 1
    @test data.len_delay_int == Int64(D_delay / Δd)

    @test sum(data.gen_int) ≈ 1
    @test sum(data.delay_int) ≈ 1

    @test size(data.delay_kernel) == (time_horizon, time_horizon)
end


@testitem "Renewal function: internal generate infs" begin
    using LinearAlgebra
    gen_int = [0.2, 0.3, 0.5]
    delay_int = [0.1, 0.4, 0.5]
    cluster_coeff = 0.8
    time_horizon = 10
    transformation = exp

    data = EpiData(gen_int, delay_int, cluster_coeff, time_horizon, transformation)
    epimodel = Renewal(data)

    function generate_infs(recent_incidence, Rt)
        new_incidence = Rt * dot(recent_incidence, epimodel.data.gen_int)
        [new_incidence; recent_incidence[1:(epimodel.data.len_gen_int-1)]], new_incidence
    end

    recent_incidence = [10, 20, 30]
    Rt = 1.5

    expected_new_incidence = Rt * dot(recent_incidence, [0.2, 0.3, 0.5])
    expected_output =
        [expected_new_incidence; recent_incidence[1:2]], expected_new_incidence


    @test generate_infs(recent_incidence, Rt) == expected_output
end

@testitem "ExpGrowthRate function" begin
    gen_int = [0.2, 0.3, 0.5]
    delay_int = [0.1, 0.4, 0.5]
    cluster_coeff = 0.8
    time_horizon = 10
    transformation = exp

    data = EpiData(gen_int, delay_int, cluster_coeff, time_horizon, transformation)
    rt_model = ExpGrowthRate(data)

    recent_incidence = [10.0, 20.0, 30.0]
    log_init = log(5.0)
    rt = [log(recent_incidence[1]) - log_init; diff(log.(recent_incidence))]

    @test rt_model(rt, (init = log_init,)) ≈ recent_incidence
end

@testitem "DirectInfections function" begin
    gen_int = [0.2, 0.3, 0.5]
    delay_int = [0.1, 0.4, 0.5]
    cluster_coeff = 0.8
    time_horizon = 10
    transformation = exp

    data = EpiData(gen_int, delay_int, cluster_coeff, time_horizon, transformation)
    direct_inf_model = DirectInfections(data)

    log_incidence = [10, 20, 30] .|> log

    expected_incidence = exp.(log_incidence)

    @test direct_inf_model(log_incidence, nothing) ≈ expected_incidence
end
