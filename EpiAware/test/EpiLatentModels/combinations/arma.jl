@testitem "Testing ARMA constructor" begin
    using Distributions, Turing

    # Test default constructor
    arma_model = arma()
    @test arma_model isa AR
    @test arma_model.ϵ_t isa MA
    @test length(arma_model.damp_prior) == 1
    @test length(arma_model.init_prior) == 1
    @test length(arma_model.ϵ_t.θ) == 1
    @test arma_model.damp_prior == filldist(truncated(Normal(0.0, 0.05), 0, 1), 1)
    @test arma_model.ϵ_t.θ == filldist(truncated(Normal(0.0, 0.05), -1, 1), 1)

    # Test with custom parameters
    damp_prior = truncated(Normal(0.0, 0.04), 0, 1)
    θ_prior = truncated(Normal(0.0, 0.06), 0, 1)
    init_prior = Normal(1.0, 0.5)

    custom_arma = arma(;
        init = [init_prior, init_prior],
        damp = [damp_prior, damp_prior],
        θ = [θ_prior, θ_prior],
        ϵ_t = HierarchicalNormal()
    )

    @test custom_arma isa AR
    @test custom_arma.ϵ_t isa MA
    @test length(custom_arma.damp_prior) == 2
    @test length(custom_arma.init_prior) == 2
    @test length(custom_arma.ϵ_t.θ) == 2
    @test custom_arma.damp_prior == filldist(damp_prior, 2)
    @test custom_arma.init_prior == filldist(init_prior, 2)
    @test custom_arma.ϵ_t.θ == filldist(θ_prior, 2)
end
