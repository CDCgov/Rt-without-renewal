@testitem "Testing ARIMA constructor" begin
    using Distributions, Turing

    # Test default constructor
    arima_model = arima()
    @test arima_model isa DiffLatentModel
    @test arima_model.model isa AR
    @test arima_model.model.ϵ_t isa MA
    @test length(arima_model.model.damp_prior) == 1
    @test length(arima_model.model.init_prior) == 1
    @test length(arima_model.model.ϵ_t.θ) == 1
    @test arima_model.model.damp_prior ==
          filldist(truncated(Normal(0.0, 0.05), 0, 1), 1)
    @test arima_model.model.ϵ_t.θ ==
          filldist(truncated(Normal(0.0, 0.05), -1, 1), 1)

    # Test with custom parameters
    ar_init_prior = Normal(1.0, 0.5)
    diff_init_prior = Normal(0.0, 0.3)
    damp_prior = truncated(Normal(0.0, 0.04), 0, 1)
    θ_prior = truncated(Normal(0.0, 0.06), -1, 1)

    custom_arima = arima(;
        ar_init = [ar_init_prior, ar_init_prior],
        diff_init = [diff_init_prior, diff_init_prior],
        damp = [damp_prior, damp_prior],
        θ = [θ_prior, θ_prior],
        ϵ_t = HierarchicalNormal()
    )

    @test custom_arima isa DiffLatentModel
    @test custom_arima.model isa AR
    @test custom_arima.model.ϵ_t isa MA
    @test length(custom_arima.model.damp_prior) == 2
    @test length(custom_arima.model.init_prior) == 2
    @test length(custom_arima.model.ϵ_t.θ) == 2
    @test custom_arima.model.damp_prior == filldist(damp_prior, 2)
    @test custom_arima.model.init_prior == filldist(ar_init_prior, 2)
    @test custom_arima.model.ϵ_t.θ == filldist(θ_prior, 2)
end
