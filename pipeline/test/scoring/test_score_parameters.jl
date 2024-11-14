# @testset "score_parameter tests" begin
#     using MCMCChains

#     samples = MCMCChains.Chains(0.5 .+ randn(1000, 2, 1), [:a, :b])
#     truths = fill(0.5, 2)
#     result = score_parameters(["a", "b"], samples, truths)

#     @test result.parameter == ["a", "b"]
#     #Bias should be close to 0 in this example
#     @test all(result.bias .< 0.1)
# end
