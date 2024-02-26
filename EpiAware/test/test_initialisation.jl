@testitem "Testing default_initialisation_prior" begin
    using Distributions
    prior = EpiAware.default_initialisation_prior()

    @test haskey(prior, :I0_prior)
    @test typeof(prior[:I0_prior]) <: Normal
end

@testitem "Testing initialize_incidence" begin
    using Distributions, Turing
    using HypothesisTests: ExactOneSampleKSTest, pvalue
    initialisation_prior = (; I0_prior = Normal())
    I0_model = EpiAware.initialize_incidence(; initialisation_prior...)

    n_samples = 2000
    I0_samples = [rand(I0_model) for _ in 1:n_samples] .|> x -> x[:_I0]
    #Check that the samples are drawn from the correct distribution
    ks_test_pval = ExactOneSampleKSTest(I0_samples, initialisation_prior.I0_prior) |> pvalue

    @test ks_test_pval > 1e-6 #Very unlikely to fail if the model is correctly implemented
end
