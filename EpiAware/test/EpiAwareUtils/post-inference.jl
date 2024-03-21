@testitem "Testing spread_draws function" begin
    using DataFramesMeta, Turing

    # Test case 1: Testing with non-empty Chains object
    @testset "Test case 1" begin
        X = rand(100, 2, 3)
        chn = Chains(X, [:a, :b])
        expected_df = DataFrame()
        expected_df[!, ".draw"] = 1:300
        expected_df[!, ".iteration"] = repeat(1:100, 3)
        expected_df[!, ".chain"] = vcat(fill(1, 100), fill(2, 100), fill(3, 100))
        expected_df.a = X[:, 1, :] |> vec
        expected_df.b = X[:, 2, :] |> vec

        df = spread_draws(chn)
        @test df == expected_df
    end
end
