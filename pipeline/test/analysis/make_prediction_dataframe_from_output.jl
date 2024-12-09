@testset "test dataframe construct for one dataset" begin
    using JLD2, DataFramesMeta
    output = load(joinpath(@__DIR__(), "test_data.jld2"))
    true_mean_gi = 10.0

    df = make_prediction_dataframe_from_output(output, true_mean_gi)
    @test !isempty(df)
    @test "Scenario" in names(df)
    @test "IGP_Model" in names(df)
    @test "Latent_Model" in names(df)
    @test "True_GI_Mean" in names(df)
    @test "Used_GI_Mean" in names(df)
    @test "Reference_Time" in names(df)
    @test "Target" in names(df)
    @test "q_025" in names(df)
    @test "q_25" in names(df)
    @test "q_5" in names(df)
    @test "q_75" in names(df)
    @test "q_975" in names(df)
end
