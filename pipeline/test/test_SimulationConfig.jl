
# Test the TruthSimulationConfig struct constructor
@testset "TruthSimulationConfig" begin
    using Distributions, .AnalysisPipeline, EpiAware
    gi = Gamma(2, 2)
    config = TruthSimulationConfig(
        truth_process = [0.5, 0.8, 1.2], generation_distribution = gi)

    @testset "truth_Rt" begin
        @test config.truth_process == [0.5, 0.8, 1.2]
        @test config.generation_distribution == gi
        @test config.igp == Renewal
    end
end
