let
    using Distributions, Turing, DynamicPPL
    μ = 10.0
    n = 10
    nb_obs_model = PoissonError()
    Y_t = fill(μ, n)
    @model function test_model(Y_t, n)
        μ ~ filldist(truncated(Normal(10, 1); lower = 0), n)
        @submodel generate_observations(nb_obs_model, Y_t, μ)
    end
    mdl = test_model(Y_t, n)
    suite["PoissonError"] = make_turing_suite(mdl; check = true)
end
