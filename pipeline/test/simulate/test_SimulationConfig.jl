
# Test the TruthSimulationConfig struct constructor
@testset "TruthSimulationConfig" begin
    using Distributions, LogExpFunctions
    logit_daily_ascertainment = [fill(1.0, 5); fill(0.5, 2)]
    normed_daily_ascertainment = logit_daily_ascertainment |> x -> 7 * softmax(x)
    config = TruthSimulationConfig(
        truth_process = [0.5, 0.8, 1.2], gi_mean = 3.0, gi_std = 2.0, logit_daily_ascertainment = logit_daily_ascertainment,
        cluster_factor = 0.1, I0 = 100.0)

    @testset "truth_Rt" begin
        @test config.truth_process == [0.5, 0.8, 1.2]
        @test config.gi_mean == 3.0
        @test config.gi_std == 2.0
        @test 7 * softmax(config.logit_daily_ascertainment) == normed_daily_ascertainment
        @test config.cluster_factor == 0.1
        @test config.I0 == 100.0
        @test config.igp == Renewal
    end
end
