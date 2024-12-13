@testset "make_truthdata_dataframe tests" begin
    truth_data = Dict(
        "I_t" => [10, 20, 30],
        "truth_I0" => 5,
        "truth_gi_mean" => 2.5,
        "truth_process" => [1.0, 1.5, 2.0]
    )
    scenario = "test_scenario"

    df = make_truthdata_dataframe(truth_data, scenario)

    @test typeof(df) == DataFrame
    @test size(df, 1) == 9  # 3 targets * 3 time points
    @test all(df.Scenario .== scenario)
    @test all(df.True_GI_Mean .== truth_data["truth_gi_mean"])
    @test all(df.Target .==
              ["log_I_t", "log_I_t", "log_I_t", "rt", "rt", "rt", "Rt", "Rt", "Rt"])
end
