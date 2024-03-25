
# @testitem "epi_solve Tests" begin
#     # Test case 1: Check if the model is created correctly
#     @testset "Model Creation" begin
#         epiproblem = EpiProblem(tspan = [1, 10], epi_model = SIRModel(), latent_model = SEIRModel(), observation_model = PoissonModel())
#         method = NUTSampler(ndraws = 100)
#         data = EpiData(y_t = [10, 20, 30, 40, 50])
#         chn = epi_solve(epiproblem, method, data)
#         @test typeof(chn) == Chains
#         @test haskey(chn, :y_t)
#         @test length(chn[:y_t]) == 100
#     end

#     # Test case 2: Check if the inference runs without errors
#     @testset "Inference Execution" begin
#         epiproblem = EpiProblem(tspan = [1, 10], epi_model = SIRModel(), latent_model = SEIRModel(), observation_model = PoissonModel())
#         method = NUTSampler(ndraws = 100)
#         data = EpiData(y_t = [10, 20, 30, 40, 50])
#         chn = epi_solve(epiproblem, method, data)
#         @test typeof(chn) == Chains
#         @test haskey(chn, :y_t)
#         @test length(chn[:y_t]) == 100
#     end
# end
