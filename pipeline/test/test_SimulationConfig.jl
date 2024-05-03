
# Test the TruthSimulationConfig struct constructor
@testset "TruthSimulationConfig" begin
    using Distributions, .AnalysisPipeline, EpiAware
    gi = Gamma(2, 2)
    config = TruthSimulationConfig(
        truth_process = [0.5, 0.8, 1.2], gi_mean = 3.0, gi_std = 2.0)

    @testset "truth_Rt" begin
        @test config.truth_process == [0.5, 0.8, 1.2]
        @test config.gi_mean == 3.0
        @test config.gi_std == 2.0
        @test config.igp == Renewal
    end
end
